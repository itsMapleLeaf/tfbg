class_name Player
extends CharacterBody2D

# TODO: make these export vars
const PLAYER_SPEED := 500
const GRAVITY := 2000
const JUMP_SPEED := 800
const TERMINAL_VELOCITY := 2000
const GRAB_STIFFNESS := 12

enum Facing { LEFT = -1, RIGHT = 1 }

@export var grab_dot: Area2D
@export var grabbed_block: Node2D

var movement := 0.0
var jumps := 2
var is_alive := false
var facing := Facing.RIGHT
var grabbing := false
var uses_input := false

@onready var grabbed_block_origin := grabbed_block.position

signal block_released(position: Vector2, direction: int)

func _process(delta: float) -> void:
	if is_alive:
		modulate.a = lerp(modulate.a, 1.0, delta * 5)
		
		if uses_input:
			var target_movement := Input.get_action_strength("right") - Input.get_action_strength("left")
			movement = lerp(movement, target_movement, clamp(delta * 10, 0, 1))

		velocity.x = movement * PLAYER_SPEED
		velocity.y += min(GRAVITY * delta, TERMINAL_VELOCITY)
		move_and_slide()
		
		if is_on_floor(): jumps = 2
	else:
		modulate.a = 0

	grabbed_block.visible = grabbing
	grab_dot.visible = !grabbing
	grabbed_block.position = lerp(grabbed_block.position, grabbed_block_origin, delta * GRAB_STIFFNESS)
	
	# https://godotengine.org/qa/92282/why-my-character-scale-keep-changing?show=146969#a146969
	match facing:
		Facing.RIGHT:
			scale.y = 1
			rotation_degrees = 0
		Facing.LEFT:
			scale.y = -1
			rotation_degrees = 180

func _input(event: InputEvent):
	if not uses_input: return
	
	if event.is_action_pressed("left"):
		facing = Facing.LEFT
		
	elif event.is_action_pressed("right"):
		facing = Facing.RIGHT
	
	elif event.is_action_pressed("grab"):
		for body in grab_dot.get_overlapping_bodies():
			if body is FallingBlock:
				grabbing = true
				grabbed_block.global_position = body.global_position
				body.queue_free()
				break
	
	elif event.is_action_released("grab") && grabbing:
		grabbing = false
		block_released.emit(grab_dot.global_position, facing)

	elif event.is_action_pressed("jump") && jumps > 0:
		velocity.y = -JUMP_SPEED
		jumps -= 1

func respawn(pos: Vector2):
	is_alive = true
	global_position = pos
	velocity = Vector2(0, 0)
	modulate.a = 0
	movement = 0

func kill():
	is_alive = false
	grabbing = false
	jumps = 0
