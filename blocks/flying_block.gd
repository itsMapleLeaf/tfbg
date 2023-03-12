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
signal destroyed

var frozen: bool:
	get: return current_freeze_time > 0

func _process(delta: float):
	life -= delta
	if life < 0:
		_destroy()
		return
	
	if frozen:
		current_freeze_time -= delta
		return

	position.x += speed * direction * delta

func _physics_process(delta: float):
	if frozen: return

	for body in get_overlapping_bodies():
		var falling_block := body as FallingBlock
		if falling_block:
			if remaining_hits > 0:
				falling_block.destroy()
				current_freeze_time = freeze_time
				remaining_hits -= 1
			else:
				hits_exhausted.emit()
				queue_free()
			return
		
		var player := body as Player
		if player and player != owner_player and player.is_alive:
			player_hit.emit(body)
			return
	
	for area in get_overlapping_areas():
		var flying_block := area as FlyingBlock
		if flying_block:
			_destroy()
			return

func _destroy():
	queue_free()
	Explosion.create(self)
	destroyed.emit()
