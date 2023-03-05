extends CharacterBody2D

const GRAVITY := 300

var life := 12.0

func _process(delta: float):
	velocity.y += GRAVITY * delta
	move_and_slide()
	
	life -= delta
	if life <= 0:
		queue_free()
