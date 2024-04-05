class_name MachineInstance extends ContainerEntityInstance

@export var input_inventory := Inventory.new()
@export var output_inventory := Inventory.new()
@export var recipe_id: String:
	set(val):
		if val == recipe_id: return
		recipe_id = val
		
		input_inventory.whitelist = []
		for i in recipe.ingredients:
			input_inventory.whitelist.append_array(Item.all_valid_items(i.selector).map(func (v: Item): return v.id))

var craft_progress := 0

var recipe: Recipe:
	get:
		return Recipe.get_recipe(recipe_id)

var machine_data: MachineData:
	get:
		return MachineData.get_machine_data(data_id)

func add_item(item: ItemStack) -> int:
	input_inventory.add_item(item)
	
	return 0

func remove_item(item: ItemStack) -> bool:
	output_inventory.take_item(item)
	
	return false

func on_tick() -> void:
	craft_progress += 1
	if craft_progress >= recipe.craft_time:
		craft_progress = 0
		craft()

func craft() -> void:
	var success := input_inventory.perform_recipe_id(recipe_id, output_inventory)
	if not success: return
	print("Post-Craft Input: " + str(input_inventory.items))
	print("Post-Craft Output: " + str(output_inventory.items))

func on_click() -> void:
	print("Input: " + str(input_inventory.items))
	print("Output: " + str(output_inventory.items))
