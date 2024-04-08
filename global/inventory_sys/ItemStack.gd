class_name ItemStack extends Resource

signal display_update
signal id_changed
signal count_changed

@export var item_id: String:
	set(val):
		if val == item_id: return
		item_id = val
		
		id_changed.emit()
		display_update.emit()

@export var count: int:
	set(val):
		if val == count: return
		count = val
		
		count_changed.emit()
		display_update.emit()

var item: Item:
	get: return Item.get_item(item_id)

func _init(item_id := "", count := 0) -> void:
	self.item_id = item_id
	self.count = count

func _to_string() -> String:
	return item_id + " x" + str(count)
