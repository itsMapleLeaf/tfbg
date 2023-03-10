extends GPUParticles2D
class_name Explosion

func _ready():
	emitting = true
	one_shot = true
	modulate.a = 1

func _process(delta: float):
	if not emitting: queue_free()

static func create(source: Node2D) -> void:
	var explosion := preload("res://explosion.tscn").instantiate() as Explosion
	explosion.global_position = source.global_position
	explosion.modulate = Color(source.modulate, 1)
	source.get_parent().add_child(explosion)
