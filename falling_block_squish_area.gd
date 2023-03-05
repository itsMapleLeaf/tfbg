extends Area2D
	
func _physics_process(delta: float):
	for body in get_overlapping_bodies():
		if body is Player and body.is_on_floor() and body.is_alive:
			body.squished.emit()
