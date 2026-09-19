extends Node2D

@onready var clients = $Clients.get_children()

var served_clients: int = 0

func _ready() -> void:
	for client in clients:
		clients.served.connect(_on_client_served)

	GameTimer.reset(60.0)
	GameTimer.start()

func _on_client_served():
	served_clients += 1

	if served_clients == clients.size():
		_finish_level()


func _finish_level():
	GameManager.next_level()
