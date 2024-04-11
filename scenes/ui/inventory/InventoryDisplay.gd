class_name InventoryDisplay extends GridContainer

@export var inventory: Inventory:
	set(val):
		if val == inventory: return
		
		if inventory and inventory.items_changed.is_connected(update): inventory.items_changed.disconnect(update)
		val.items_changed.connect(update)
		
		inventory = val
		
		update()

@export var config: InventoryDisplayConfig

var rendered_ids: Array[String] = []

func update_rendered_items() -> void:
	for i: ItemDisplay in get_children():
		if not i.stack: continue
		
		if inventory.get_item_count(i.stack.item_id) < 1:
			rendered_ids.erase(i.stack.item_id)
			i.stack = null
			continue
		
		if inventory.get_item_count(i.stack.item_id) != i.stack.count:
			i.stack = inventory.filter_items(i.stack.item_id)[0]

func render_items() -> void:
	for i in inventory.items:
		if rendered_ids.has(i.item_id): continue
		
		add_child(ItemDisplay.new(i, inventory, config))
		rendered_ids.push_back(i.item_id)

func sort_with_function(sort_function: Callable) -> void:
	var sorted := get_children().filter(func (v: ItemDisplay): return global.to_bool(v.stack))
	sorted.sort_custom(sort_function)
	
	for i in range(sorted.size()): move_child(sorted[i], i)

func sort() -> void:
	match config.sort_mode:
		InventoryDisplayConfig.SortMode.NAME:
			sort_with_function(func (a: ItemDisplay, b: ItemDisplay):
				if not a.stack: return false
				if not b.stack: return true
				return a.stack.item.name.naturalnocasecmp_to(b.stack.item.name) < 0
			)
		
		InventoryDisplayConfig.SortMode.QUANTITY:
			sort_with_function(func (a: ItemDisplay, b: ItemDisplay):
				if not a.stack: return false
				if not b.stack: return true
				return b.stack.count > a.stack.count
			)

func fill_empty() -> void:
	var expected_rows: int = ceil(float(rendered_ids.size()) / float(columns)) + config.extra_rows
	var expected_children := expected_rows * columns
	
	if get_child_count() > expected_children:
		for i in range(get_child_count() - expected_children):
			var child: ItemDisplay = get_child(-1)
			remove_child(child)
			child.queue_free()
		
		return
	
	for i in range(expected_children - get_child_count()):
		var blank := ItemDisplay.new(null, inventory, config)
		add_child(blank)

func update() -> void:
	if inventory.needs_simplify: return inventory.simplify()
	
	update_rendered_items()
	render_items()
	sort()
	fill_empty()
