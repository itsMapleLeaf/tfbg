class_name GameCamera
extends Camera2D

@export var look_offset: Vector2
@export var stiffness: float

var target_position := global_position
var target_zoom := Vector2(1, 1)
var look_enabled := true

func _process(delta: float):
	var look_input := Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up"),
	)
	
	var target := target_position
	if look_enabled:
		target += look_input * look_offset
	
	global_position = lerp(global_position, target, delta * stiffness)
	zoom = lerp(zoom, target_zoom, delta * stiffness)
