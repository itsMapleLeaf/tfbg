extends Node2D
class_name Game

const BLOCK_SPAWN_HEIGHT_BLOCKS := 20
const CAMERA_OFFSET := Vector2(0, -80)

@onready var players: Array[Player] = [
	_create_player(Color.from_string("#f46078", Color.WHITE), preload("res://player/human_player_controller.gd").new()),
	_create_player(Color.from_string("#c174f5", Color.WHITE), preload("res://player/robot_player_controller.tscn").instantiate()),
	_create_player(Color.from_string("#c174f5", Color.WHITE), preload("res://player/robot_player_controller.tscn").instantiate()),
	_create_player(Color.from_string("#c174f5", Color.WHITE), preload("res://player/robot_player_controller.tscn").instantiate()),
]
@onready var main_player := players[0]
@export var player_spawns: Node2D
@export var player_fallout: Node2D

@export var camera: GameCamera
@export var camera_wide_view_position_node: Node2D
@export var camera_shaker: CameraShaker

@export var falling_block_spawn_left: Node2D
@export var falling_block_spawn_right: Node2D

func _ready():
	for player in players: _respawn_player(player)

	_update_camera(main_player)
	camera.reset_smoothing()

func _process(delta: float):
	for player in players:
		if player.global_position.y >= player_fallout.global_position.y && player.is_alive:
			_kill_player(player)
			
	_update_camera(main_player)

func _on_falling_block_spawn_timer_timeout():
	var x = randf_range(falling_block_spawn_left.global_position.x, falling_block_spawn_right.global_position.x)
	var y = randf_range(falling_block_spawn_left.global_position.y, falling_block_spawn_right.global_position.y)
	_create_falling_block(Vector2(x,y))

func _create_player(color: Color, controller: Node) -> Player:
	var player := preload("res://player/player.tscn").instantiate() as Player
	player.modulate = color
	player.block_released.connect(_create_flying_block.bind(player))
	player.respawn_timeout.connect(_respawn_player.bind(player))
	player.add_child(controller)
	add_child(player)
	return player

func _respawn_player(player: Player):
	var spawn_count := player_spawns.get_child_count()
	var spawn := player_spawns.get_child(randi() % spawn_count) as Node2D
	player.respawn(spawn.global_position)

func _kill_player(player: Player):
	if player.kill():
		camera_shaker.shake()
	
func _update_camera(player: Player):
	if player.is_alive:
		camera.target_position = player.global_position + CAMERA_OFFSET
		camera.target_zoom = Vector2(1.5, 1.5)
	else:
		camera.target_position = camera_wide_view_position_node.global_position
		camera.target_zoom = Vector2(0.8, 0.8)

func _create_falling_block(new_position: Vector2):
	var block := preload("res://blocks/falling_block.tscn").instantiate() as FallingBlock
	block.global_position = new_position
	block.player_squished.connect(_kill_player)
	block.destroyed.connect(camera_shaker.shake.bind(0.5))
	block.grounded.connect(camera_shaker.shake.bind(0.1))
	add_child(block)

func _create_flying_block(new_position: Vector2, direction: int, owner_player: Player):
	var block := preload("res://blocks/flying_block.tscn").instantiate() as FlyingBlock
	block.global_position = new_position
	block.direction = direction
	block.owner_player = owner_player
	block.hits_exhausted.connect(func (): _create_falling_block(block.global_position))
	block.player_hit.connect(_kill_player)
	block.destroyed.connect(camera_shaker.shake.bind(0.4))
	add_child(block)
