class_name MachineData extends Resource

static var list := {}

@export var tile_id: String:
	set(val):
		tile_id = val
		list[tile_id] = self
@export var crafting_rate_multi: float = 1

static func get_machine_data(id: String) -> MachineData:
	return list.get(id)
