class_name MachineInstance extends ContainerEntityInstance

const machine_ui_scene: PackedScene = preload("res://scenes/ui/inventory/machine/MachineUI.tscn")

@export var recipe_id: String:
	set(val):
		if val == recipe_id: return
		recipe_id = val
		
		input_inventory.whitelist = []
		if not recipe: return
		for i in recipe.ingredients:
			input_inventory.whitelist.append_array(Item.all_valid_items(i.selector).map(func (v: Item): return v.id))

var input_inventory := Inventory.new()
var output_inventory := Inventory.new()
var craft_progress: float = 0

var recipe: Recipe:
	get:
		return Recipe.get_recipe(recipe_id)

var machine_data: MachineData:
	get:
		return MachineData.get_machine_data(data_id)

func get_input() -> Inventory:
	return input_inventory

func get_output() -> Inventory:
	return output_inventory

func get_primary_inventory() -> Inventory:
	return input_inventory

func on_tick(delta: float) -> void:
	if not recipe or not input.has_atleast_all_ingredients(recipe.ingredients):
		craft_progress = 0
		return
	
	craft_progress += delta
	
	if craft_progress >= recipe.craft_time:
		for i in floor(craft_progress / recipe.craft_time): craft()
	
	craft_progress = fmod(craft_progress, recipe.craft_time)

func craft() -> void:
	var success := input.perform_recipe_id(recipe_id, output)
	if not success: return

func on_click() -> void:
	var node: MachineUI = machine_ui_scene.instantiate()
	node.machine = self
	global.show_panel(node)
