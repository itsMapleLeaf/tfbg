class_name PauseMenu
extends CenterContainer

signal resume

@export var resume_button: Button

func _ready():
	resume_button.grab_focus()

func _on_resume_button_pressed():
	resume.emit()

func _on_title_button_pressed():
	get_tree().change_scene_to_file("res://title_menu/title_menu.tscn")
