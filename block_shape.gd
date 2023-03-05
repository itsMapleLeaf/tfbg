extends CollisionShape2D
class_name BlockShape

var global_rect: Rect2:
	get:
		var rect_shape := shape as RectangleShape2D
		return Rect2(rect_shape.position, rect_shape.size)
