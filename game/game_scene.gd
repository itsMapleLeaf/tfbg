extends Node

@onready var game = $Game
@onready var ui = $UI
var menu: PauseMenu

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("game_pause"):
		if menu == null:
			_pause()
		else:
			_unpause()

func _pause() -> void:
	menu = preload("res://game/pause_menu.tscn").instantiate() as PauseMenu
	menu.resume.connect(_unpause)
	ui.add_child(menu)
	game.process_mode = Node.PROCESS_MODE_DISABLED

func _unpause() -> void:
	if menu == null: return
	ui.remove_child(menu)
	menu = null
	game.process_mode = Node.PROCESS_MODE_INHERIT
