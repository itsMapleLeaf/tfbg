extends Button

func _ready():
	grab_focus()

func _pressed():
	get_tree().change_scene_to_file("res://game/game.tscn")

