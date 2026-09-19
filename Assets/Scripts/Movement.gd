extends CharacterBody2D

@export_category("Movement")
@export var move_speed: float = 650.0
@export var acceleration: float = 4000.0
@export var friction: float = 5000.0
@export var air_control_multiplier: float = 0.8

@export_category("Wall Climb")
@export var wall_run_min_speed: float = 400.0     # vitesse mini au sol pour déclencher
@export var wall_climb_speed: float = 500.0        # vitesse de montée le long du mur
@export var wall_stick_speed: float = 60.0         # petite poussée horizontale pour rester collé au mur
@export var wall_run_rotation_speed: float = 12.0

var _wall_run_active: bool = false
var _wall_run_dir: float = 0.0  # 1 = mur à droite (tu courais vers la droite), -1 = mur à gauche

@export_category("Jump")
@export var jump_velocity: float = -420.0
@export var jump_forward_multiplier: float = 1.3
@export var min_jump_forward_boost: float = 300.0
@export var gravity_scale: float = 1.0
@export var fall_gravity_multiplier: float = 1.6
@export var low_jump_gravity_multiplier: float = 2.2
@export var max_fall_speed: float = 1000.0

@export_category("Feel / Forgiveness")
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.1 

var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _was_on_floor: bool = false

@export_category("Attack")
@export var attack_action: String = "attack"
@export var attack_damage: int = 1
@export var attack_cooldown: float = 0.4

var _attack_cooldown_timer: float = 0.0

@onready var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var sprite: Node2D = get_node_or_null("Sprite2D")
@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var attack_area: Area2D = get_node_or_null("AttackArea")

signal jumped
signal landed

func _physics_process(delta: float) -> void:
	_handle_timers(delta)

	if _wall_run_active:
		_handle_wall_climb(delta)
	else:
		_handle_gravity(delta)
		_handle_jump_input(delta)
		_handle_horizontal_movement(delta)

	var pre_slide_velocity: Vector2 = velocity
	var pre_slide_on_floor: bool = is_on_floor()
	_was_on_floor = pre_slide_on_floor

	move_and_slide()

	if _wall_run_active:
		_check_wall_climb_end()
	else:
		_check_wall_climb_trigger(pre_slide_velocity, pre_slide_on_floor)

	if is_on_floor() and not _was_on_floor:
		landed.emit()
		if _wall_run_active:
			_end_wall_climb()

	_update_animation()
	_handle_attack(delta)

func _handle_timers(delta: float) -> void:
	if is_on_floor():
		_coyote_timer = coyote_time
	else:
		_coyote_timer = max(_coyote_timer - delta, 0.0)
	_jump_buffer_timer = max(_jump_buffer_timer - delta, 0.0)

func _handle_gravity(delta: float) -> void:
	if is_on_floor():
		return

	var g := gravity * gravity_scale

	if velocity.y < 0.0 and not Input.is_action_pressed("jump"):
		g *= low_jump_gravity_multiplier
	elif velocity.y > 0.0:
		g *= fall_gravity_multiplier

	velocity.y = min(velocity.y + g * delta, max_fall_speed)

func _handle_jump_input(_delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = jump_buffer_time

	var can_jump := _coyote_timer > 0.0
	if _jump_buffer_timer > 0.0 and can_jump:
		velocity.y = jump_velocity
		var facing_dir: float = signf(velocity.x) if absf(velocity.x) > 10.0 else (1.0 if not sprite else signf(sprite.scale.x))
		var boost: float = max(absf(velocity.x) * jump_forward_multiplier, min_jump_forward_boost)
		velocity.x = facing_dir * boost
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0
		jumped.emit()

func _handle_horizontal_movement(delta: float) -> void:
	var input_dir := Input.get_axis("move_left", "move_right")
	var target_speed := input_dir * move_speed

	var accel := acceleration if input_dir != 0.0 else friction
	if not is_on_floor():
		accel *= air_control_multiplier

	velocity.x = move_toward(velocity.x, target_speed, accel * delta)

	if sprite and input_dir != 0.0:
		sprite.scale.x = abs(sprite.scale.x) * sign(input_dir)

	if animated_sprite and input_dir != 0.0:
		animated_sprite.flip_h = input_dir < 0.0

func _check_wall_climb_trigger(pre_slide_velocity: Vector2, pre_slide_on_floor: bool) -> void:
	if not is_on_wall():
		return
	if absf(pre_slide_velocity.x) < wall_run_min_speed:
		return

	var input_dir := Input.get_axis("move_left", "move_right")
	# on ne déclenche que si tu tiens encore la touche vers le mur que tu viens de percuter
	if input_dir == 0.0 or sign(input_dir) != sign(pre_slide_velocity.x):
		return

	_wall_run_active = true
	_wall_run_dir = sign(pre_slide_velocity.x)

func _handle_wall_climb(delta: float) -> void:
	velocity.y = -wall_climb_speed
	velocity.x = _wall_run_dir * wall_stick_speed  # garde le perso collé au mur

	if animated_sprite:
		var target_angle := deg_to_rad(90.0) * -_wall_run_dir
		animated_sprite.rotation = lerp_angle(animated_sprite.rotation, target_angle, wall_run_rotation_speed * delta)
		animated_sprite.flip_h = _wall_run_dir < 0.0

	if sprite:
		sprite.scale.x = abs(sprite.scale.x) * _wall_run_dir

func _check_wall_climb_end() -> void:
	var input_dir: float = Input.get_axis("move_left", "move_right")
	var still_holding: bool = input_dir != 0.0 and sign(input_dir) == _wall_run_dir

	if not is_on_wall() or not still_holding:
		_end_wall_climb()

func _end_wall_climb() -> void:
	_wall_run_active = false
	_wall_run_dir = 0.0
	if animated_sprite:
		animated_sprite.rotation = 0.0

func _update_animation() -> void:
	if not animated_sprite:
		return

	var input_dir := Input.get_axis("move_left", "move_right")
	var is_moving := absf(velocity.x) > 10.0 and input_dir != 0.0

	if _wall_run_active or is_moving:
		if animated_sprite.animation != "run":
			animated_sprite.play("run")
	else:
		if animated_sprite.animation != "idle":
			animated_sprite.play("idle")

func _handle_attack(delta: float) -> void:
	_attack_cooldown_timer = max(_attack_cooldown_timer - delta, 0.0)

	if not attack_area:
		return

	if Input.is_action_just_pressed(attack_action) and _attack_cooldown_timer <= 0.0:
		_attack_cooldown_timer = attack_cooldown

		for body in attack_area.get_overlapping_bodies():
			if body.is_in_group("enemy") and body.has_method("take_damage"):
				body.take_damage(attack_damage)
