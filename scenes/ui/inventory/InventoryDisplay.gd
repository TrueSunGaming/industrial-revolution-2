class_name InventoryDisplay extends GridContainer

@export var inventory: Inventory:
	set(val):
		if val == inventory: return
		
		if inventory and inventory.items_changed.is_connected(update): inventory.items_changed.disconnect(update)
		val.items_changed.connect(update)
		
		inventory = val
		
		update()

@export var config: InventoryDisplayConfig

func update() -> void:
	if inventory.needs_simplify: return inventory.simplify()
	
	var rendered_ids: Array[String] = []
	
	for i: ItemDisplay in get_children():
		if not i.stack or inventory.get_item_count(i.stack.item_id) < 1:
			remove_child(i)
			i.queue_free()
			continue
		
		rendered_ids.push_back(i.stack.item_id)
		
		if inventory.get_item_count(i.stack.item_id) != i.stack.count:
			i.stack = inventory.filter_items(i.stack.item_id)[0]
	
	for i in inventory.items:
		if rendered_ids.has(i.item_id): continue
		
		add_child(ItemDisplay.new(i, inventory, config))
	
	match config.sort_mode:
		"Name":
			global.sort_children(self, func (a: ItemDisplay, b: ItemDisplay):
				return a.stack.item.name.naturalnocasecmp_to(b.stack.item.name) < 0
			)
		
		"Quantity":
			global.sort_children(self, func (a: ItemDisplay, b: ItemDisplay):
				return b.stack.count > a.stack.count
			)
	
	var last_row := get_child_count() % columns
	var rows: int = ceil(float(get_child_count()) / float(columns))
	
	for i in range((rows + config.extra_rows) * columns - last_row):
		var blank := ItemDisplay.new(null, inventory, config)
		add_child(blank)
