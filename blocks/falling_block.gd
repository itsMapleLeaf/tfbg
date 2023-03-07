extends CharacterBody2D
class_name FallingBlock

const GRAVITY := 800.0
const TERMINAL_VELOCITY := 600.0

@export var position_snap_stiffness: float
@export var shape: CollisionShape2D
@export var squish_area: Area2D

enum State {
	FALLING,
	STATIC,
	DESPAWNING,
}

var state := State.FALLING
var life := 10.0
var speed := 0.0

signal player_squished(player: Player)

func _process(delta: float):
	position.x = lerp(position.x, round_to_nearest(position.x, 50.0), delta * position_snap_stiffness)
	if state == State.STATIC:
		position.y = lerp(position.y, round_to_nearest(position.y, 50.0), delta * position_snap_stiffness)
	
	squish_area.get_node("CollisionShape2D").disabled = state == State.DESPAWNING
	
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
			
func _physics_process(delta: float):
	for body in squish_area.get_overlapping_bodies():
		if body is Player and body.is_on_floor() and body.is_alive:
			player_squished.emit(body)
			
func _move(movement: float):
	var collision := move_and_collide(Vector2(0, movement), true)
	if collision:
		var collider := collision.get_collider() 
		if collider is MapBlock or (collider is FallingBlock and collider.state == State.STATIC):
			position += collision.get_travel()
			state = State.STATIC
			return
			
	position += Vector2(0, movement)

func round_to_nearest(num: float, multiple: float) -> float:
	return round(num / multiple) * multiple
