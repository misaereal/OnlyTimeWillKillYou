extends Node2D

func _ready() -> void:
	GameTimer.reset(60.0)
	GameTimer.start()
