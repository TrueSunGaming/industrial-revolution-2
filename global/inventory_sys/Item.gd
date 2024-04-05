class_name Item extends Resource

enum Type {
	ITEM,
	FLUID
}

static var list := {}

@export var name: String
@export var id: String:
	set(val):
		id = val
		list[id] = self
@export var texture: Texture2D
@export_multiline var description: String
@export var type: Type
@export var tags: Array[String] = []

static func get_item(id: String) -> Item:
	return list.get(id)

func satisfies_selector(selector: String) -> bool:
	var split := selector.split(";")
	var parts: Array[String] = []
	
	for i in split: parts.push_back(i.strip_edges())
	
	if parts.size() < 1: return false
	if parts.has("*"): return true
	if parts.has("*item") and type == Type.ITEM: return true
	if parts.has("*fluid") and type == Type.FLUID: return true
	
	for i in parts:
		if i == id: return true
		if i.begins_with("#") and tags.has(i.trim_prefix("#")): return true
	
	return false

static func id_satisfies_selector(id: String, selector: String) -> bool:
	return get_item(id).satisfies_selector(selector)

static func all_valid_items(selector: String) -> Array[Item]:
	var res: Array[Item] = []
	
	for i in list.values():
		if i.satisfies_selector(selector): res.push_back(i)
	
	return res
