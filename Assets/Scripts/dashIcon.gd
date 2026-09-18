extends Sprite2D

@export var player_path: NodePath
@export var trigger_distance: float = 150.0
@export var slide_offset: Vector2 = Vector2(-200, 0)
@export var debug_print: bool = false
@export var animation_duration: float = 0.4

var _player: Node2D
var _shown_position: Vector2
var _hidden_position: Vector2
var _reference_global_position: Vector2
var _is_hidden: bool = false
var _tween: Tween

func _ready() -> void:
	_player = get_node_or_null(player_path)
	_shown_position = position
	_hidden_position = position + slide_offset
	_reference_global_position = global_position

func _process(_delta: float) -> void:
	if not _player:
		return

	var distance := _reference_global_position.distance_to(_player.global_position)
	var should_hide := distance < trigger_distance

	if debug_print:
		print("distance: ", distance, " should_hide: ", should_hide, " is_hidden: ", _is_hidden)

# yo stuxy pls dont delete this debug thanks ^^^^

	if should_hide and not _is_hidden:
		_is_hidden = true
		_animate_to(_hidden_position)
	elif not should_hide and _is_hidden:
		_is_hidden = false
		_animate_to(_shown_position)

func _animate_to(target: Vector2) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "position", target, animation_duration)
