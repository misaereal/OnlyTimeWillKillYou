extends CharacterBody2D

signal served

@export var interact_action: String = "interact"

var is_served: bool = false
var _player_in_range: bool = false

@onready var interaction_area: Area2D = get_node_or_null("Area2D")

func _ready() -> void:
	if interaction_area:
		interaction_area.body_entered.connect(_on_body_entered)
		interaction_area.body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if is_served or not _player_in_range:
		return

	if Input.is_action_just_pressed(interact_action):
		serve()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_in_range = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_in_range = false

func serve():
	if is_served:
		return

	is_served = true
	served.emit()
