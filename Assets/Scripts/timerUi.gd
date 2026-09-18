extends Label

@export var low_time_threshold: float = 10.0
@export var normal_color: Color = Color.WHITE
@export var low_time_color: Color = Color.RED

func _ready() -> void:
	GameTimer.time_changed.connect(_on_time_changed)
	_on_time_changed(GameTimer.time_remaining)

func _on_time_changed(time_remaining: float) -> void:
	text = GameTimer.get_time_formatted()
	modulate = low_time_color if time_remaining <= low_time_threshold else normal_color
