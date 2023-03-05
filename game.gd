extends Node2D

const MAP_PLATFORM_WIDTH_BLOCKS := 40
const PLAYER_SPAWN_HEIGHT_BLOCKS := 6
const BLOCK_SPAWN_HEIGHT_BLOCKS := 20
const PLAYER_FALLOUT_DEPTH := 2000

var map_block_scene := preload("res://map_block.tscn")
var player_scene := preload("res://player.tscn")
var camera_scene := preload("res://game_camera.tscn")

@onready var player := player_scene.instantiate() as Player

func _ready():
	_create_map_blocks()
	
	add_child(player)
	
	var camera := camera_scene.instantiate() as GameCamera
	camera.player = player
	camera.pan_out_position = Vector2(0, -PLAYER_SPAWN_HEIGHT_BLOCKS) * Globals.BLOCK_SIZE_PIXELS
	add_child(camera)
	
	player.respawn(_get_player_spawn_position())
	
func _create_map_blocks():
	for i in 3:
		var block := map_block_scene.instantiate() as StaticBody2D
		block.position = Vector2(0, i) * Globals.BLOCK_SIZE_PIXELS
		block.scale = Vector2(MAP_PLATFORM_WIDTH_BLOCKS - i * 2, 1)
		add_child(block)

func _create_player():
	player.respawn(_get_player_spawn_position())
	
func _get_player_spawn_position() -> Vector2:
	return Vector2(
		randi_range(0, MAP_PLATFORM_WIDTH_BLOCKS) - MAP_PLATFORM_WIDTH_BLOCKS / 2,
		-BLOCK_SPAWN_HEIGHT_BLOCKS
	) * Globals.BLOCK_SIZE_PIXELS

func _process(delta: float):
	if player.global_position.y >= PLAYER_FALLOUT_DEPTH && player.is_alive:
		_kill_player(player)

func _kill_player(player: Player):
	player.kill()
	await get_tree().create_timer(2).timeout
	player.respawn(_get_player_spawn_position())
