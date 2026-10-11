extends Control

@onready var Play : TextureButton = $Play
@onready var Settings : TextureButton = $Settings
@onready var Quit : TextureButton = $Quit

func _ready() -> void:
	SoundManager.play_music("MUSIC_MENU")


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/level_1.tscn")

func _on_settings_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
