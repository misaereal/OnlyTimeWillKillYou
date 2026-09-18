extends CharacterBody2D

@export_category("Movement")
@export var move_speed: float = 650.0
@export var acceleration: float = 4000.0
@export var friction: float = 5000.0
@export var air_control_multiplier: float = 0.8

@export_category("Jump")
@export var jump_velocity: float = -620.0
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

@onready var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var sprite: Node = get_node_or_null("Sprite2D")

signal jumped
signal landed

func _physics_process(delta: float) -> void:
	_handle_timers(delta)
	_handle_gravity(delta)
	_handle_jump_input(delta)
	_handle_horizontal_movement(delta)

	_was_on_floor = is_on_floor()
	move_and_slide()

	if is_on_floor() and not _was_on_floor:
		landed.emit()

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
