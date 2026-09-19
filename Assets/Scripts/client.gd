extends CharacterBody2D

signal served

var is_served: bool = false


func serve():
	if is_served:
		return

	is_served = true
	served.emit()
