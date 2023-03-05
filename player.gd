class_name Player
extends CharacterBody2D

const PLAYER_SPEED := 500
const GRAVITY := 2000
const JUMP_SPEED := 800
const TERMINAL_VELOCITY := 2000

var movement := 0.0
var jumps := 2
var is_alive := false
var look := 0.0

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

func _input(event: InputEvent):
	if event.is_action_pressed("jump") && jumps > 0:
		velocity.y = -JUMP_SPEED
		jumps -= 1

func respawn(pos: Vector2):
	is_alive = true
	position = pos
	velocity = Vector2(0, 0)
	modulate.a = 0
	movement = 0

func kill():
	is_alive = false
