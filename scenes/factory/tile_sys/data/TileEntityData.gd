class_name TileEntityData extends Resource

static var list := {}

@export var id: String:
	set(val):
		id = val
		list[id] = self
@export var name: String
@export_multiline var description: String
@export var placement_size := Vector2(1, 1)
@export_range(0, 360) var rotation_step: float
@export var scene: PackedScene
@export var tags: Array[String] = []
@export var item_id: String:
	set(val):
		if val == item_id: return
		
		Item.tile_list.erase(item_id)
		Item.tile_list[val] = self
		
		item_id = val
@export var break_time: float = 30

var breakable: bool:
	get:
		return break_time >= 0

static func get_tile_data(tile_id: String) -> TileEntityData:
	return list.get(tile_id)
