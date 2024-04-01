class_name Recipe extends Resource

static var list := {}

@export var id: String
@export var ingredients: Array[ItemStack]
@export var result: Array[ItemStack]
@export var name_override: String

func _init(id: String, ingredients: Array[ItemStack], result: Array[ItemStack], name_override := "") -> void:
	self.id = id
	self.ingredients = ingredients
	self.result = result
	self.name_override = name_override
	list[id] = self

static func get_recipe(id: String) -> Recipe:
	return list.get(id)
