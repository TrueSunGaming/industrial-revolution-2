class_name ItemDisplay extends TextureRect

@export var stack: ItemStack:
	set(val):
		stack = val.duplicate()
		
		update()

var count_label: Label

func _ready() -> void:
	count_label = Label.new()
	add_child(count_label)
	
	update()

func update() -> void:
	texture = stack.item.texture if stack else refs.blank_texture
	tooltip_text = str(stack) if stack else "Empty slot"
	if count_label: count_label.text = str(stack.count) if stack else ""
