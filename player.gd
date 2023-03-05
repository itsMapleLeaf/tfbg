class_name Player
extends CharacterBody2D

@export var camera: Camera2D
@export var map_area: Area2D
@export var camera_death_point: Node2D

const PLAYER_SPEED := 500
const GRAVITY := 2000
const JUMP_SPEED := 800
const TERMINAL_VELOCITY := 2000

var movement := 0.0
var jumps := 2
var is_alive := false
var look := 0

func _ready():
	map_area.body_exited.connect(_map_area_body_exited)
	_respawn()

func _process(delta: float) -> void:
	if is_alive:
		modulate.a = lerp(modulate.a, 1.0, delta * 5)
		
		var target_movement := Input.get_action_strength("right") - Input.get_action_strength("left")
		movement = lerp(movement, target_movement, clamp(delta * 10, 0, 1))
			
		look = Input.get_action_strength("down") - Input.get_action_strength("up")

		velocity.x = movement * PLAYER_SPEED
		velocity.y += min(GRAVITY * delta, TERMINAL_VELOCITY)

		move_and_slide()

		var collision := get_last_slide_collision()
		if collision && collision.get_normal().y < 0:
			jumps = 2
	else:
		modulate.a = 0
	

func _map_area_body_exited(body: Node2D):
	if body == self: _kill()
	
func _kill():
	is_alive = false
	await get_tree().create_timer(2).timeout
	_respawn()

func _respawn():
	is_alive = true
	position = Vector2(0, -10) * Globals.BLOCK_SIZE_PIXELS
	velocity = Vector2(0, 0)
	modulate.a = 0
	movement = 0

func _input(event: InputEvent):
	if event.is_action_pressed("jump") && jumps > 0:
		velocity.y = -JUMP_SPEED
		jumps -= 1
