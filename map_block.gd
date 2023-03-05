extends StaticBody2D

@export var world_position: Vector2

func _ready():
	position = world_position * Globals.BLOCK_SIZE_PIXELS
