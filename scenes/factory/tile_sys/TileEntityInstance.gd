class_name TileEntityInstance extends Resource

signal world_attached(world)
signal world_removed
signal world_tick(delta)

static var next_id := 0
static var list := {}

@export var data_id: String
@export var position: Vector2

var node_ref: Node2D
var id: int
var world: TileWorld:
	set(val):
		if val == world: return
		world = val
		
		if val != null:
			world_attached.emit(val)
			world.tick.connect(relay_tick)
			world.tile_render.emit(id)
		else:
			world_removed.emit()
			if world.tick.is_connected(relay_tick): world.tick.disconnect(relay_tick)

var tile_data: TileEntityData:
	get:
		return TileEntityData.get_tile_data(data_id)

var placement_rect: Rect2:
	get:
		return Rect2(position, tile_data.placement_size)

var index: int:
	get:
		if not world: return -1
		
		return world.tiles.find(func (v): return v.id == id)

func _init() -> void:
	id = next_id
	next_id += 1
	
	list[id] = self

static func get_tile(id: int) -> TileEntityInstance:
	return list.get(id)

func remove_from_world() -> void:
	if not world: return
	
	var idx := world.tiles.find(func (v: TileEntityInstance): return v.id == id)
	world.tiles.remove_at(idx)
	
	world.tile_removed.emit(id)

func relay_tick(delta: float) -> void:
	world_tick.emit(delta)
