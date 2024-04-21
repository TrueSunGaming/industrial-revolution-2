class_name TileWorld extends Resource

signal tile_placed(id: int, idx: int)
signal tile_removed(id: int)
signal tile_render(id: int)
signal tick(delta: float)

static var tei_factory := TileEntityInstanceFactory.new()

enum PlaceStatus {
	OK,
	ERROR_UNKNOWN,
	ERROR_NOT_FOUND,
	ERROR_EXISTING_TILE,
	ERROR_PLAYER
}

@export var tile_size: Vector2

@export var tiles: Array[TileEntityInstance]:
	set(val):
		for i in range(val.size()):
			if tiles.any(func (v: TileEntityInstance): return v.id == val[i].id): continue
			
			tile_placed.emit(val[i].id, i)
			val[i].world = self
		
		tiles = val

var render_buffer: Array[int] = []
var tile_cache := {}

var can_place_held_item: PlaceStatus:
	get:
		if not global.item_on_mouse: return PlaceStatus.ERROR_NOT_FOUND
		
		return can_place_tile_id(
			global.item_on_mouse.item_id,
			world_to_tile(refs.world_container.get_local_mouse_position()).floor()
		)

func _init() -> void:
	tile_placed.connect(func (id: int, _idx: int):
		tile_render.emit(id)
		
		var instance := TileEntityInstance.get_tile(id)
		if not instance: return
		
		for x in range(instance.position.x, instance.position.x + instance.tile_data.placement_size.x):
			for y in range(instance.position.y, instance.position.y + instance.tile_data.placement_size.y):
				if not tile_cache.has(Vector2i(x, y)): tile_cache[Vector2i(x, y)] = []
				tile_cache[Vector2i(x, y)].push_back(instance)
	)
	
	tile_removed.connect(func (id: int):
		var instance := TileEntityInstance.get_tile(id)
		if not instance: return
		
		for x in range(instance.position.x, instance.position.x + instance.tile_data.placement_size.x):
			for y in range(instance.position.y, instance.position.y + instance.tile_data.placement_size.y):
				tile_cache[Vector2i(x, y)].erase(instance)
				if tile_cache[Vector2i(x, y)].size() < 1: tile_cache.erase(Vector2i(x, y))
	)
	
	tile_render.connect(func (id: int):
		render_buffer.push_back(id)
	)

func can_place_tile(tile: TileEntityInstance) -> PlaceStatus:
	for x in range(tile.position.x, tile.position.x + tile.tile_data.placement_size.x):
		for y in range(tile.position.y, tile.position.y + tile.tile_data.placement_size.y):
			if tile_cache.has(Vector2i(x, y)): return PlaceStatus.ERROR_EXISTING_TILE
	
	return PlaceStatus.OK

func place_tile(tile: TileEntityInstance) -> PlaceStatus:
	var can_place := can_place_tile(tile)
	if can_place != PlaceStatus.OK: return can_place
	
	tiles.push_back(tile)
	tile.world = self
	
	tile_placed.emit(tile.id, tiles.size() - 1)
	
	return PlaceStatus.OK

func can_place_tile_id(item_id: String, position: Vector2, rotation := 0.0) -> PlaceStatus:
	var instance := tei_factory.generate_positioned(item_id, position, rotation)
	if not instance: return PlaceStatus.ERROR_NOT_FOUND
	
	var can_place := can_place_tile(instance)
	instance.remove()
	
	return can_place

func place_tile_id(item_id: String, position: Vector2, rotation := 0.0) -> PlaceStatus:
	var instance := tei_factory.generate_positioned(item_id, position, rotation)
	if not instance: return PlaceStatus.ERROR_NOT_FOUND
	
	return place_tile(instance)

func place_held_item() -> PlaceStatus:
	var can_place := can_place_held_item
	if can_place != PlaceStatus.OK: return can_place
	
	var status := place_tile_id(
		global.item_on_mouse.item_id,
		world_to_tile(refs.world_container.get_local_mouse_position()).floor()
	)
	
	if status != PlaceStatus.OK: return status
	
	global.item_on_mouse.count -= 1
	if global.item_on_mouse.count < 1:
		global.item_on_mouse = null
		global.item_on_mouse_original_inventory = null
	
	return PlaceStatus.OK

func tile_at(tile: Vector2) -> TileEntityInstance:
	var cached: Variant = tile_cache.get(Vector2i(tile.floor()))
	if cached and cached.size() > 0: return cached[0]
	
	return null

func tiles_at(tile: Vector2) -> Array[TileEntityInstance]:
	var cached: Variant = tile_cache.get(Vector2i(tile.floor()))
	if not cached: return []
	
	var res: Array[TileEntityInstance] = []
	for i in cached: res.push_back(i)
	
	return res

func remove_tile_at(tile: Vector2, free_tile := false) -> TileEntityInstance:
	var entity := tile_at(tile)
	if not entity: return null
	
	entity.remove_from_world(free_tile)
	
	return null if free_tile else entity

func process_tick(delta: float) -> void:
	tick.emit(delta)

func tile_to_world(tile: Vector2) -> Vector2:
	return tile * tile_size - tile_size / 2

func world_to_tile(world: Vector2) -> Vector2:
	return world / tile_size + Vector2(0.5, 0.5)
