class_name MachineUI extends UIPanel

@onready var recipe_display: RecipeDisplay = $PanelContent/HBoxContainer/VBoxContainer2/TabContainer/Craft/HBoxContainer/RecipeDisplay
@onready var input_display: InventoryDisplay = $PanelContent/HBoxContainer/VBoxContainer2/TabContainer/Input/Input
@onready var output_display: InventoryDisplay = $PanelContent/HBoxContainer/VBoxContainer2/TabContainer/Output/Output
@onready var progress_bar: ProgressBar = $PanelContent/HBoxContainer/VBoxContainer2/TabContainer/Craft/HBoxContainer/ProgressBar
@onready var progress_bar_container: HBoxContainer = $PanelContent/HBoxContainer/VBoxContainer2/TabContainer/Craft/HBoxContainer
@onready var player_inventory: InventoryDisplay = $PanelContent/HBoxContainer/VBoxContainer/ScrollContainer/InventoryDisplay

@export var machine: MachineInstance:
	set(val):
		if val == machine: return
		machine = val

var tile_data: TileEntityData:
	get:
		return TileEntityData.get_tile_data(machine.machine_data.tile_id)

func _process(_delta: float) -> void:
	progress_bar.value = 100 * machine.craft_progress / machine.recipe.craft_time if machine.recipe else 0.0
	recipe_display.recipe_id = machine.recipe_id
	progress_bar.custom_minimum_size.x = progress_bar_container.size.x - recipe_display.size.x - 4
	input_display.inventory = machine.input
	output_display.inventory = machine.output
	player_inventory.config.shift_inventory = machine.input
	title = tile_data.name
	recipe_display.valid_recipe_selector = machine.machine_data.recipe_selector

func _ready() -> void:
	player_inventory.inventory = refs.player.inventory
	input_display.config.shift_inventory = refs.player.inventory
	output_display.config.shift_inventory = refs.player.inventory

func _on_recipe_display_set_recipe(id: String) -> void:
	machine.recipe_id = id
