extends Node2D

@onready var clients = $Clients.get_children()

var served_clients: int = 0
var _level_ended: bool = false

func _ready() -> void:
	for client in clients:
		client.served.connect(_on_client_served)

	GameTimer.time_up.connect(_on_time_up)

	GameTimer.reset(60.0)
	GameTimer.start()

func _on_client_served():
	if _level_ended:
		return

	served_clients += 1

	if served_clients == clients.size():
		_finish_level()

func _on_time_up():
	if _level_ended:
		return

	_fail_level()

func _finish_level():
	_level_ended = true
	GameTimer.stop()
	GameManager.next_level()

func _fail_level():
	_level_ended = true
	GameTimer.stop()
	GameManager.fail_level()
