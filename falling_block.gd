extends CharacterBody2D
class_name FallingBlock

const GRAVITY := 800.0
const TERMINAL_VELOCITY := 600.0

@export var shape: CollisionShape2D
@export var squish_area_shape: CollisionShape2D

enum State {
	FALLING,
	STATIC,
	DESPAWNING,
}

var state := State.FALLING
var life := 10.0
var speed := 0.0

func _process(delta: float):
	squish_area_shape.disabled = state == State.DESPAWNING
	
	match state:
		State.FALLING:
			speed = min(speed + GRAVITY * delta, TERMINAL_VELOCITY)
			_move(speed * delta)
			
		State.STATIC:
			life -= delta
			if life <= 0:
				state = State.DESPAWNING
				speed = 0
				shape.disabled = true
			
		State.DESPAWNING:
			speed = min(speed + GRAVITY * delta, TERMINAL_VELOCITY)
			position.y += speed * delta
			
			modulate.a -= delta
			if modulate.a <= 0: queue_free()

func _move(movement: float):
	var collision := move_and_collide(Vector2(0, movement), true)
	if collision:
		var collider := collision.get_collider() 
		if collider is MapBlock or (collider is FallingBlock and collider.state == State.STATIC):
			position += collision.get_travel()
			state = State.STATIC
			return
			
	position += Vector2(0, movement)
