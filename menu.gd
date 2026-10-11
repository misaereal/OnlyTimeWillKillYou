extends Area2D

@export var target_scene: PackedScene

func _ready() -> void:
	input_event.connect(_on_input_event)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if target_scene:
			get_tree().change_scene_to_packed(target_scene)
