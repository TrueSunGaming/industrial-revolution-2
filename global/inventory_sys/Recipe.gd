class_name Recipe extends Resource

static var list := {}

@export var id: String:
	set(val):
		id = val
		list[id] = self
@export var ingredients: Array[RecipeIngredient] = []
@export var result: Array[ItemStack] = []
@export var tags: Array[String] = []

@export var craft_time: int

@export_group("Display Overrides")
@export var name_override: String
@export var icon_override: Texture2D

@export_group("Fuel")
@export var fuel_consumption: float
@export var allow_item_fuel := true
@export var allow_liquid_fuel := true

var name: String:
	get:
		return name_override if name_override.length() > 0 else result[0].item.name

var icon: Texture2D:
	get:
		return icon_override if icon_override else result[0].item.texture

static func get_recipe(id: String) -> Recipe:
	return list.get(id)

func satisfies_selector(selector: String) -> bool:
	var split := selector.split(";")
	var parts: Array[String] = []
	
	for i in split: parts.push_back(i.strip_edges())
	
	if parts.size() < 1: return false
	if parts.has("*"): return true
	if parts.has("*creator") and ingredients.size() == 0: return true
	if fuel_consumption > 0:
		if parts.has("*fueled"): return true
		if parts.has("*item_fueled") and allow_item_fuel: return true
		if parts.has("*liquid_fueled") and allow_liquid_fuel: return true
	
	for i in parts:
		if i == id: return true
		if i.begins_with("#") and tags.has(i.trim_prefix("#")): return true
	
	return false

static func id_satisfies_selector(id: String, selector: String) -> bool:
	return get_recipe(id).satisfies_selector(selector)

static func all_valid_recipes(selector: String) -> Array[Recipe]:
	var res: Array[Recipe] = []
	
	for i in list.values():
		if i.satisfies_selector(selector): res.push_back(i)
	
	return res
