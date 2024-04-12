class_name TileWorld extends Resource

signal tile_placed(id: int, idx: int)
signal tile_removed(id: int)
signal tile_render(id: int)
signal tick(delta: float)

static var tei_factory := TileEntityInstanceFactory.new()

@export var tile_size: Vector2

@export var tiles: Array[TileEntityInstance]:
	set(val):
		for i in range(val.size()):
			if tiles.any(func (v: TileEntityInstance): return v.id == val[i].id): continue
			
			tile_placed.emit(val[i].id, i)
			val[i].world = self
		
		tiles = val

var render_buffer: Array[int] = []

func _init() -> void:
	tile_placed.connect(func (id: int, _idx: int):
		tile_render.emit(id)
	)
	
	tile_render.connect(func (id: int):
		render_buffer.push_back(id)
	)

func place_tile(tile: TileEntityInstance) -> bool:
	if tiles.any(func (v: TileEntityInstance):
		return v.placement_rect.intersects(tile.placement_rect)
	): return false
	
	tiles.push_back(tile)
	tile.world = self
	
	tile_placed.emit(tile.id, tiles.size() - 1)
	
	return true

func place_tile_id(item_id: String, position: Vector2, rotation := 0.0) -> bool:
	var instance := tei_factory.generate_positioned(item_id, position, rotation)
	if not instance: return false
	
	return place_tile(instance)

func place_held_item() -> bool:
	if not global.item_on_mouse: return false
	
	var success := place_tile_id(
		global.item_on_mouse.item_id,
		world_to_tile(refs.world_container.get_local_mouse_position()).floor()
	)
	
	if not success: return false
	
	global.item_on_mouse.count -= 1
	if global.item_on_mouse.count < 1:
		global.item_on_mouse = null
		global.item_on_mouse_original_inventory = null
	
	return true

func tile_at(tile: Vector2) -> TileEntityInstance:
	var filtered := tiles.filter(func (v: TileEntityInstance): return v.placement_rect.has_point(tile))
	
	return filtered[0] if filtered.size() > 0 else null

func remove_tile_at(tile: Vector2) -> TileEntityInstance:
	var entity := tile_at(tile)
	if entity: entity.remove_from_world()
	
	return entity

func process_tick(delta: float) -> void:
	tick.emit(delta)

func tile_to_world(tile: Vector2) -> Vector2:
	return tile * tile_size - tile_size / 2

func world_to_tile(world: Vector2) -> Vector2:
	return world / tile_size + Vector2(0.5, 0.5)
