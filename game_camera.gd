class_name GameCamera
extends Camera2D

var player: Player
var pan_out_position: Vector2

const MOVEMENT_LOOK_FACTOR := Vector2(0.65, 0.3)
const OFFSET := Vector2(0, -80)
const STIFFNESS := 5
const LOOK_DISTANCE := 220

@onready var target_position := global_position
var target_zoom := Vector2(1, 1)

func _process(delta: float):
	if player.is_alive:
		target_position = \
			player.global_position + \
			(player.velocity * MOVEMENT_LOOK_FACTOR) + \
			player.look * Vector2(0, LOOK_DISTANCE) + \
			OFFSET
			
		target_zoom = Vector2(1, 1)
	else:
		target_position = pan_out_position
		target_zoom = Vector2(0.5, 0.5)
	
	global_position = lerp(global_position, target_position, delta * STIFFNESS)
	zoom = lerp(zoom, target_zoom, delta * 5)
