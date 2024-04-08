class_name ItemDisplay extends TextureRect

@export var stack: ItemStack:
	set(val):
		stack = val.duplicate() if val else null
		
		update()

@export var pickable := false
@export var droppable := false
@export var inventory: Inventory
@export var shift_inventory: Inventory

var count_label: Label

func _ready() -> void:
	count_label = Label.new()
	add_child(count_label)
	
	update()

func update() -> void:
	texture = stack.item.texture if stack else refs.blank_texture
	tooltip_text = str(stack) if stack else "Empty slot"
	if count_label: count_label.text = str(stack.count) if stack else ""

func _gui_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("pick_half"):
		if Input.is_physical_key_pressed(KEY_SHIFT):
			return quick_transfer(Input.is_action_just_pressed("pick_half"))
		swap_with_mouse(Input.is_action_just_pressed("pick_half"))

func put_on_mouse(half := false) -> void:
	if not stack: return
	if not pickable: return
	if global.item_on_mouse: return
	
	var half_stack := ItemStack.new(stack.item_id, ceil(stack.count / 2.0)) if half else stack
	
	global.item_on_mouse = half_stack
	global.item_on_mouse_original_inventory = inventory
	
	if inventory: inventory.take_item(half_stack)

func quick_transfer(half := false) -> void:
	if not pickable: return
	if not stack: return
	if not shift_inventory: return
	
	var half_stack := ItemStack.new(stack.item_id, ceil(stack.count / 2.0)) if half else stack
	
	var amount_added := shift_inventory.add_item(half_stack)
	if inventory: inventory.take_item(ItemStack.new(stack.item_id, amount_added))

func drop_item(half := false) -> void:
	if not droppable: return
	
	var half_stack: ItemStack = ItemStack.new(global.item_on_mouse.item_id, ceil(global.item_on_mouse.count / 2.0)) if half else global.item_on_mouse
	
	if not inventory:
		stack = half_stack
		global.item_on_mouse.count -= half_stack.count
		
		if global.item_on_mouse.count < 1:
			global.item_on_mouse = null
			global.item_on_mouse_original_inventory = null
		
		return
	
	if not global.item_on_mouse: return
	
	var amount_added := inventory.add_item(half_stack)
	global.item_on_mouse.count -= amount_added
	
	if global.item_on_mouse.count < 1:
		global.item_on_mouse = null
		global.item_on_mouse_original_inventory = null

func swap_with_mouse(half := false) -> void:
	if global.item_on_mouse: return drop_item(half)
	if stack: put_on_mouse(half)
