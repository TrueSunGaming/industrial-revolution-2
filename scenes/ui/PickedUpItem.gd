class_name PickedUpItem extends ItemDisplay

func update_pickup() -> void:
	visible = global.to_bool(global.item_on_mouse)
	stack = global.item_on_mouse

func _process(delta: float) -> void:
	super(delta)
	global_position = get_global_mouse_position() - texture.get_size() / 2
