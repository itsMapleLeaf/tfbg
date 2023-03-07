class_name GameCamera
extends Camera2D

@export var look_offset: Vector2
@export var stiffness: Vector2
@export var zoom_stiffness: float

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
	
	global_position.x = lerp(global_position.x, target.x, delta * stiffness.x)
	global_position.y = lerp(global_position.y, target.y, delta * stiffness.y)
	zoom = lerp(zoom, target_zoom, delta * zoom_stiffness)
