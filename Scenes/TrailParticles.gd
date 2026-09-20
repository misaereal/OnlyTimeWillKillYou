extends Node2D

@onready var particles: GPUParticles2D = $GPUParticles2D

@export var min_distance: float = 8.0
@export var min_speed: float = 30.0

var player: Node2D
var last_emit_position: Vector2
var last_player_position: Vector2

func _ready() -> void:
	player = get_parent()  # marche si TrailParticles est instanciée en enfant direct du Player
	particles.emitting = false
	particles.one_shot = true
	last_emit_position = player.global_position
	last_player_position = player.global_position

func _physics_process(delta: float) -> void:
	var current_pos := player.global_position
	var speed := current_pos.distance_to(last_player_position) / delta
	last_player_position = current_pos

	if speed < min_speed:
		return

	if current_pos.distance_to(last_emit_position) >= min_distance:
		last_emit_position = current_pos
		particles.restart()
