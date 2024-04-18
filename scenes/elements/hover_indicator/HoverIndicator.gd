class_name HoverIndicator extends Node2D

@export var instance_id := -1:
	set(val):
		var instance := TileEntityInstance.get_tile(val)
		
		visible = instance != null or instance_id < 0
		
		if val == instance_id: return
		instance_id = val
		
		if not instance: 
			if instance_id >= 0:
				printerr("Failed to focus HoverIndicator on " + str(instance_id) + ": Instance not found")
			return
		
		rect = instance.render_rect

@export var rect: Rect2:
	set(val):
		if val == rect: return
		rect = val
		
		position = val.position
		tile_size = val.size

var tile_size: Vector2:
	set(val):
		if val == tile_size: return
		tile_size = val
		
		$TopRight.position.x = val.x
		$BottomLeft.position.y = val.y
		$BottomRight.position = val

func _ready() -> void:
	refs.hover_indicator = self
