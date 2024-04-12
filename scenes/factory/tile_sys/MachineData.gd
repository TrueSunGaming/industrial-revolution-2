class_name MachineData extends Resource

static var list := {}

@export var tile_id: String:
	set(val):
		tile_id = val
		list[tile_id] = self
@export var crafting_rate_multi: float = 1
@export var recipe_selector := "*"

var valid_recipes: Array[Recipe]:
	get:
		return Recipe.all_valid_recipes(recipe_selector)

static func get_machine_data(id: String) -> MachineData:
	return list.get(id)
