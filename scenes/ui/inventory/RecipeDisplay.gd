class_name RecipeDisplay extends TextureRect

signal clicked
signal set_recipe(id: String)

const recipe_select_scene: PackedScene = preload("res://scenes/ui/inventory/machine/RecipeSelect.tscn")

@export var opens_selector := false:
	set(val):
		opens_selector = val

@export var recipe_id: String:
	set(val):
		if recipe_id and val == recipe_id: return
		recipe_id = val
		
		texture = recipe.icon if recipe else refs.blank_texture
		tooltip_text = recipe.name if recipe else "No recipe"

@export var valid_recipe_selector := "*"

var recipe: Recipe:
	get:
		return Recipe.get_recipe(recipe_id)

var selector_open := false

func open_selector() -> Variant:
	if selector_open: return null
	
	selector_open = true
	
	var selector := recipe_select_scene.instantiate()
	selector.valid_recipe_selector = valid_recipe_selector
	var result: Variant = await global.show_data_panel(selector)
	
	selector_open = false
	
	return result

func _gui_input(_event: InputEvent) -> void:
	if not Input.is_action_just_released("interact"): return
	clicked.emit()
	
	if not opens_selector: return
	
	var result: Variant = await open_selector()
	
	if result is String: set_recipe.emit(result)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
