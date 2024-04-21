class_name Item extends Resource

enum Type {
	ITEM,
	FLUID
}

static var list := {}
static var tile_list := {}

@export var name: String
@export_multiline var description: String
@export var id: String:
	set(val):
		id = val
		list[id] = self
@export var texture: Texture2D
@export var type: Type
@export var tags: Array[String] = []
@export var fuel_value: float

var tile: TileEntityData:
	get:
		return tile_list.get(id)

static func get_item(item_id: String) -> Item:
	return list.get(item_id)

func satisfies_selector(selector: String) -> bool:
	var split := selector.split(";")
	var parts: Array[String] = []
	
	for i in split: parts.push_back(i.strip_edges())
	
	if parts.size() < 1: return false
	if parts.has("*"): return true
	if parts.has("*item") and type == Type.ITEM: return true
	if parts.has("*fluid") and type == Type.FLUID: return true
	if fuel_value > 0:
		if parts.has("*fuel"): return true
		if parts.has("*item_fuel") and type == Type.ITEM: return true
		if parts.has("*fluid_fuel") and type == Type.FLUID: return true
	
	for i in parts:
		if i == id: return true
		if i.begins_with("#") and tags.has(i.trim_prefix("#")): return true
		if i.begins_with("$i") and type == Type.ITEM and fuel_value >= float(i.trim_prefix("$i")): return true
		if i.begins_with("$f") and type == Type.FLUID and fuel_value >= float(i.trim_prefix("$f")): return true
		if i.begins_with("$") and fuel_value >= float(i.trim_prefix("$")): return true
	
	return false

static func id_satisfies_selector(item_id: String, selector: String) -> bool:
	return get_item(item_id).satisfies_selector(selector)

static func all_valid_items(selector: String) -> Array[Item]:
	var res: Array[Item] = []
	
	for i in list.values():
		if i.satisfies_selector(selector): res.push_back(i)
	
	return res
