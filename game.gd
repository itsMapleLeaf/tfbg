extends Node2D

const BLOCK_SPAWN_HEIGHT_BLOCKS := 20
const CAMERA_OFFSET := Vector2(0, -80)

@export var player: Player
@export var player_spawns: Node2D
@export var player_fallout: Node2D

@export var camera: GameCamera
@export var camera_wide_view_position_node: Node2D

@export var map: GameMap

@export var falling_block_spawn_left: Node2D
@export var falling_block_spawn_right: Node2D

func _ready():
	_respawn_player()
	
	_update_camera()
	camera.reset_smoothing()
	
	_spawn_falling_blocks()
	
	player.squished.connect(_kill_player)

func _process(delta: float):
	_update_camera()
	if player.global_position.y >= player_fallout.global_position.y && player.is_alive:
		_kill_player()

func _respawn_player():
	var spawn_count := player_spawns.get_child_count()
	var spawn := player_spawns.get_child(randi() % spawn_count) as Node2D
	player.respawn(spawn.global_position)

func _kill_player():
	player.kill()
	await get_tree().create_timer(2).timeout
	_respawn_player()
	
func _update_camera():
	camera.look_enabled = player.is_alive
	if player.is_alive:
		camera.target_position = player.global_position + CAMERA_OFFSET
		camera.target_zoom = Vector2(1, 1)
	else:
		camera.target_position = camera_wide_view_position_node.global_position
		camera.target_zoom = Vector2(0.6, 0.6)

func _spawn_falling_blocks():
	while true:
		var block := preload("res://falling_block.tscn").instantiate() as FallingBlock
		block.global_position = Vector2(
			round_to_nearest(
				randf_range(falling_block_spawn_left.global_position.x, falling_block_spawn_right.global_position.x),
				50.0,
			),
			randf_range(falling_block_spawn_left.global_position.y, falling_block_spawn_right.global_position.y),
		)
		add_child(block)
		await get_tree().create_timer(0.5).timeout

func round_to_nearest(num: float, multiple: float) -> float:
	return round(num / multiple) * multiple
