extends Node2D
class_name CameraShaker

@export var intensity: float
@export var damping: float

var _amount := 0.0

func _process(delta: float) -> void:
	_amount = lerpf(_amount, 0.0, delta * damping)
	position = _amount * Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))

func shake(amount: float = 1.0) -> void:
	_amount = maxf(_amount, amount) # don't let lower amounts "downgrade" the shake
