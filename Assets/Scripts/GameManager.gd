extends Node

var current_level: int = 1

var levels = [
	"res://Scenes/level_1.tscn",
	"res://Scenes/level_2.tscn",
	"res://Scenes/level_3.tscn"
]

func next_level():
	current_level += 1

	if current_level <= levels.size():
		get_tree().change_scene_to_file(levels[current_level - 1])
	else:
		print("Game Complete!")
