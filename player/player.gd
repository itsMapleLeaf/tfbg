class_name Player
extends CharacterBody2D

# TODO: make these export vars
const PLAYER_SPEED := 500
const GRAVITY := 2000
const JUMP_SPEED := 800
const TERMINAL_VELOCITY := 2000
const GRAB_STIFFNESS := 12
const MAX_INVULNERABLE_TIME := 1.0

enum State { IDLE, GRABBING, DEAD }
enum Direction { LEFT = -1, RIGHT = 1 }

@export var grab_dot: Area2D
@export var grabbed_block: Node2D

var movement := 0.0
var target_movement := 0.0
var jumps := 2
var direction := Direction.RIGHT
var state := State.IDLE
var invulnerable_time := MAX_INVULNERABLE_TIME

@onready var grabbed_block_origin := grabbed_block.position

signal block_released(position: Vector2, direction: int)
signal found_block

var is_alive: bool:
	get: return state != State.DEAD
	
var grabbing: bool:
	get: return state == State.GRABBING

func _process(delta: float) -> void:
	if is_alive:
		movement = lerpf(movement, target_movement, clampf(delta * 10, 0, 1))

		velocity.x = movement * PLAYER_SPEED
		velocity.y += minf(GRAVITY * delta, TERMINAL_VELOCITY)
		move_and_slide()
		
		invulnerable_time -= delta

	if not is_alive:
		modulate.a = 0
	elif invulnerable_time > 0:
		modulate.a = floori(invulnerable_time / 0.1) % 2
	else:
		modulate.a = 1

	grabbed_block.visible = grabbing
	grab_dot.visible = !grabbing
	grabbed_block.position = lerp(grabbed_block.position, grabbed_block_origin, delta * GRAB_STIFFNESS)
	
	# https://godotengine.org/qa/92282/why-my-character-scale-keep-changing?show=146969#a146969
	match direction:
		Direction.RIGHT:
			scale.y = 1
			rotation_degrees = 0
		Direction.LEFT:
			scale.y = -1
			rotation_degrees = 180

func _physics_process(delta):
	if is_on_floor(): jumps = 2

func set_movement(new_movement: float):
	target_movement = signf(new_movement)
	
	var new_direction = sign(new_movement)
	if new_direction != 0.0: direction = new_direction

func jump():
	if not is_alive: return
	if jumps <= 0: return
	velocity.y = -JUMP_SPEED
	jumps -= 1

func grab() -> bool:
	if state != State.IDLE: return false
	
	var block := get_grabbable_block()
	if not block is FallingBlock: return false
	
	state = State.GRABBING
	grabbed_block.global_position = block.global_position
	block.queue_free()
	return true

func release():
	if state != State.GRABBING: return false
	state = State.IDLE
	block_released.emit(grab_dot.global_position, direction)

func respawn(pos: Vector2):
	global_position = pos
	velocity = Vector2(0, 0)
	modulate.a = 0
	movement = 0
	invulnerable_time = 1
	
	await get_tree().physics_frame # wait until positions and such are resolved before allowing grabbing
	state = State.IDLE

func kill() -> bool:
	if invulnerable_time > 0: return false
	
	state = State.DEAD
	jumps = 0
	return true

func get_grabbable_block() -> Object:
	if not is_alive: return null
	if grabbing: return null
	for body in grab_dot.get_overlapping_bodies():
		if body is FallingBlock:
			return body
	return null

func _on_grab_dot_body_entered(body):
	if body is FallingBlock:
		found_block.emit()
