extends Node2D
class_name GameMap

func get_bounds() -> Rect2:
	var blocks := get_children() as Array[MapBlock]
	var left = blocks.map(func (block: MapBlock): block.shape.global_rect.position.x).min()
	var right = blocks.map(func (block: MapBlock): block.shape.global_rect.position.x).max()
	var top = blocks.map(func (block: MapBlock): block.shape.global_rect.position.y).min()
	var bottom = blocks.map(func (block: MapBlock): block.shape.global_rect.position.y).max()
	return Rect2(left, top, right - left, bottom - top)
