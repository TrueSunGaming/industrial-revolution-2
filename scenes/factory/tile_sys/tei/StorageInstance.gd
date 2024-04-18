class_name StorageInstance extends ContainerEntityInstance

@export var inventory: Inventory

func add_item(item: ItemStack) -> int:
	return inventory.add_item(item)

func remove_item(item: ItemStack) -> bool:
	return inventory.take_item(item)
