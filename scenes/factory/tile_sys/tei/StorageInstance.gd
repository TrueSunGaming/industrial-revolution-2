class_name StorageInstance extends ContainerEntityInstance

@export var inventory: Inventory

func get_input() -> Inventory:
	return inventory

func get_output() -> Inventory:
	return inventory

func get_primary_inventory() -> Inventory:
	return inventory
