class_name Recipe extends Resource

static var list := {}

@export var id: String:
	set(val):
		id = val
		list[id] = self
@export var ingredients: Array[RecipeIngredient] = []
@export var result: Array[ItemStack] = []
@export var name_override: String
@export var tags: Array[String] = []
@export var craft_time: int

var name: String:
	get:
		return name_override if name_override.length() > 0 else result[0].item.name

static func get_recipe(id: String) -> Recipe:
	return list.get(id)
