class_name TileEntityData extends Resource

static var list := {}

@export var id: String:
	set(val):
		id = val
		list[id] = self
@export var name: String
@export var description: String
@export var placement_size := Vector2(1, 1)
@export var scene: PackedScene

static func get_tile_data(id: String) -> TileEntityData:
	return list.get(id)
