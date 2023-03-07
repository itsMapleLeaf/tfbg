extends Area2D
class_name FlyingBlock

@export var speed: float
@export var freeze_time: float
@export var max_hits: int
@export var max_life: float
@export var owner_player: Player

var direction := 1
var current_freeze_time := 0.0
@onready var life := max_life
@onready var remaining_hits := max_hits

signal hits_exhausted
signal player_hit(player: Player)

func _process(delta: float):
	life -= delta
	if life < 0:
		queue_free()
		return
	
	if current_freeze_time > 0:
		current_freeze_time -= delta
		return
	
	for body in get_overlapping_bodies():
		if body is FallingBlock:
			if remaining_hits > 0:
				body.queue_free()
				current_freeze_time = freeze_time
				remaining_hits -= 1
			else:
				hits_exhausted.emit()
				queue_free()
			return
		
		if body is Player and body != owner_player and body.is_alive:
			player_hit.emit(body)
			return
	
	position.x += speed * direction * delta
