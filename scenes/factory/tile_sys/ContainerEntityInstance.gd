class_name ContainerEntityInstance extends TileEntityInstance

var input: Inventory:
	get = get_input

var output: Inventory:
	get = get_output

var primary_inventory: Inventory:
	get = get_primary_inventory

func get_input() -> Inventory:
	assert(false, "Cannot get input inventory of abstract class ContainerEntityInstance")
	
	return null

func get_output() -> Inventory:
	assert(false, "Cannot get output inventory of abstract class ContainerEntityInstance")
	
	return null

func get_primary_inventory() -> Inventory:
	assert(false, "Cannot get primary inventory of abstract class ContainerEntityInstance")
	
	return null

func has_atleast(item: ItemStack) -> bool:
	return primary_inventory.has_atleast(item)

func input_has_atleast(item: ItemStack) -> bool:
	return input.has_atleast(item)

func output_has_atleast(item: ItemStack) -> bool:
	return output.has_atleast(item)

func transfer_item_to(item: ItemStack, other: ContainerEntityInstance) -> int:
	if not output_has_atleast(item): return 0
	
	var added := other.input.add_item(item)
	output.remove_item(ItemStack.new(item.item_id, added))
	
	return added

func transfer_item_from(item: ItemStack, other: ContainerEntityInstance) -> int:
	return other.transfer_item_to(item, self)
