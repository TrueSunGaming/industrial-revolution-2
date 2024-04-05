class_name ItemStack extends Resource

@export var item_id: String
@export var count: int

var item: Item:
	get: return Item.get_item(item_id)

func _init(item_id := "", count := 0) -> void:
	self.item_id = item_id
	self.count = count

func _to_string() -> String:
	return item_id + " x" + str(count)
