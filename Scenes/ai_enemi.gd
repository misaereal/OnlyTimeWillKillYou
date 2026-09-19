extends StaticBody2D

enum State { IDLE, ATTACK }

@export_category("Combat")
@export var max_health: int = 3
@export var attack_cooldown: float = 1.0       # temps entre deux attaques
@export var time_penalty_on_hit: float = 5.0   # secondes retirées au joueur quand il se fait toucher
@export var time_bonus_on_death: float = 2.0   # secondes rendues quand l'ennemi meurt

signal defeated

var _state: State = State.IDLE
var _health: int = max_health
var _attack_timer: float = 0.0
var _player_in_range: bool = false
var _player_ref: Node = null
var _is_dead: bool = false

@onready var detection_area: Area2D = get_node_or_null("DetectionArea")
@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")

func _ready() -> void:
	add_to_group("enemy")
	_health = max_health

	if detection_area:
		detection_area.body_entered.connect(_on_body_entered)
		detection_area.body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	if _is_dead:
		return

	_state = State.ATTACK if _player_in_range else State.IDLE

	if _state == State.ATTACK:
		_attack_timer -= delta
		if _attack_timer <= 0.0:
			_attack_timer = attack_cooldown
			_attack_player()

	_update_animation()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_in_range = true
		_player_ref = body
		_attack_timer = attack_cooldown  # petit délai avant la première attaque

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		_player_ref = null

func _attack_player() -> void:
	GameTimer.add_time(-time_penalty_on_hit)

func take_damage(amount: int = 1) -> void:
	if _is_dead:
		return

	_health -= amount

	if _health <= 0:
		_die()

func _die() -> void:
	_is_dead = true
	GameTimer.add_time(time_bonus_on_death)
	defeated.emit()
	queue_free()

func _update_animation() -> void:
	if not animated_sprite:
		return

	var anim_name := "attack" if _state == State.ATTACK else "idle"
	if animated_sprite.animation != anim_name:
		animated_sprite.play(anim_name)
