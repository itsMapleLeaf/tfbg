extends Control

@export var play_button: Button

func _ready():
	play_button.grab_focus()

func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://game/game_scene.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
