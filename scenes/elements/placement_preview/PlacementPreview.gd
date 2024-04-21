class_name PlacementPreview extends Sprite2D

@export var color_normal: Color
@export var color_error: Color

func _process(_delta: float) -> void:
	var world := refs.world_container.world
	if not world: return
	
	position = world.tile_to_world(world.world_to_tile(refs.world_container.get_local_mouse_position()).floor())
	modulate = color_normal if world.can_place_held_item == TileWorld.PlaceStatus.OK else color_error
