extends Node
class_name HumanPlayerController

var _player: Player

func _init(player: Player):
	_player = player

func _process(delta: float):
	_player.set_movement(Input.get_action_strength("right") - Input.get_action_strength("left"))

func _input(event: InputEvent):
	if event.is_action_pressed("grab"):
		_player.grab()
	elif event.is_action_released("grab"):
		_player.release()
	elif event.is_action_pressed("jump"):
		_player.jump()
