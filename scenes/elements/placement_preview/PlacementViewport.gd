class_name PlacementViewport extends SubViewport

var displayed_item := ""
var displayed_position := Vector2(0.1, 0.1)
var tile_instance_id := -1

var new_position: Vector2:
	get:
		return refs.world_container.world.world_to_tile(refs.world_container.get_local_mouse_position()).floor()

var should_rerender: bool:
	get:
		if not global.item_on_mouse: return true
		return global.item_on_mouse.item_id != displayed_item or new_position != displayed_position

func _process(_delta: float) -> void:
	update_scene()

func update_scene() -> void:
	if not should_rerender: return
	
	if has_node("PreviewScene"):
		if tile_instance_id >= 0: TileEntityInstance.get_tile(tile_instance_id).remove()
		tile_instance_id = -1
		$PreviewScene.queue_free()
		remove_child($PreviewScene)
	
	if not global.item_on_mouse or not refs.world_container.world:
		displayed_item = ""
		displayed_position = Vector2(0.1, 0.1)
		return
	
	displayed_item = global.item_on_mouse.item_id
	displayed_position = new_position
	
	var instance := TileWorld.tei_factory.generate_positioned(global.item_on_mouse.item_id, new_position)
	tile_instance_id = instance.id
	instance.world = refs.world_container.world
	
	var node := refs.world_container.create_tile_node(instance)
	node.name = "PreviewScene"
	node.global_position = Vector2()
	
	add_child(node)
