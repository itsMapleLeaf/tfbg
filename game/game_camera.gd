class_name GameCamera
extends Camera2D

@export var look_offset: Vector2
@export var stiffness: Vector2
@export var zoom_stiffness: float

var target_position := global_position
var target_zoom := Vector2(1, 1)
var look_enabled := true

func _process(delta: float):
	global_position.x = lerp(global_position.x, target_position.x, delta * stiffness.x)
	global_position.y = lerp(global_position.y, target_position.y, delta * stiffness.y)
	zoom = lerp(zoom, target_zoom, delta * zoom_stiffness)
