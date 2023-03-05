class_name GameCamera
extends Camera2D

const STIFFNESS := 5

var target_position := global_position
var target_zoom := Vector2(1, 1)

func _process(delta: float):
	global_position = lerp(global_position, target_position, delta * STIFFNESS)
	zoom = lerp(zoom, target_zoom, delta * 5)
