class_name MachineUI extends UIPanel

@export var machine: MachineInstance:
	set(val):
		if val == machine: return
		machine = val
		
		title = tile_data.name
		$PanelContent/HBoxContainer/TextureRect.texture = machine.recipe.icon
		$PanelContent/Input.inventory = val.input_inventory
		$PanelContent/Output.inventory = val.output_inventory

var tile_data: TileEntityData:
	get:
		return TileEntityData.get_tile_data(machine.machine_data.tile_id)

func _process(delta: float) -> void:
	$PanelContent/HBoxContainer/ProgressBar.value = 100 * machine.craft_progress / machine.recipe.craft_time
