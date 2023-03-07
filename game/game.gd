extends Node2D
class_name Game

const BLOCK_SPAWN_HEIGHT_BLOCKS := 20
const CAMERA_OFFSET := Vector2(0, -80)

var players: Array[Player] = []
var main_player: Player
@export var player_spawns: Node2D
@export var player_fallout: Node2D

@export var camera: GameCamera
@export var camera_wide_view_position_node: Node2D

@export var falling_block_spawn_left: Node2D
@export var falling_block_spawn_right: Node2D

func _ready():
	main_player = _create_player()
	
	var controller := preload("res://player/human_player_controller.gd").new(main_player)
	main_player.add_child(controller)

	_create_player()
	
	_update_camera(main_player)
	camera.reset_smoothing()
	
	_spawn_falling_blocks()

func _process(delta: float):
	for player in players:
		if player.global_position.y >= player_fallout.global_position.y && player.is_alive:
			_kill_player(player)
			
	_update_camera(main_player)

func _create_player() -> Player:
	var player := preload("res://player/player.tscn").instantiate() as Player
	player.block_released.connect(_create_flying_block.bind(player))
	players.append(player)
	add_child(player)
	_respawn_player(player)
	return player

func _respawn_player(player: Player):
	var spawn_count := player_spawns.get_child_count()
	var spawn := player_spawns.get_child(randi() % spawn_count) as Node2D
	player.respawn(spawn.global_position)

func _kill_player(player: Player):
	player.kill()
	await get_tree().create_timer(2).timeout
	_respawn_player(player)
	
func _update_camera(player: Player):
	camera.look_enabled = player.is_alive
	if player.is_alive:
		camera.target_position = player.global_position + CAMERA_OFFSET
		camera.target_zoom = Vector2(1, 1)
	else:
		camera.target_position = camera_wide_view_position_node.global_position
		camera.target_zoom = Vector2(0.6, 0.6)

func _spawn_falling_blocks():
	while true:
		var x = randf_range(falling_block_spawn_left.global_position.x, falling_block_spawn_right.global_position.x)
		var y = randf_range(falling_block_spawn_left.global_position.y, falling_block_spawn_right.global_position.y)
		_create_falling_block(Vector2(x,y))
		await get_tree().create_timer(0.5).timeout

func _create_falling_block(position: Vector2):
	var block := preload("res://blocks/falling_block.tscn").instantiate() as FallingBlock
	block.global_position = position
	block.player_squished.connect(_kill_player)
	add_child(block)

func _create_flying_block(position: Vector2, direction: int, owner_player: Player):
	var block := preload("res://blocks/flying_block.tscn").instantiate() as FlyingBlock
	block.global_position = position
	block.direction = direction
	block.owner_player = owner_player
	block.hits_exhausted.connect(func (): _create_falling_block(block.global_position))
	block.player_hit.connect(_kill_player)
	add_child(block)
