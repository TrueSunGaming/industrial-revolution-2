class_name InventoryDisplayConfig extends ItemDisplayConfig

enum SortMode {
	DISABLED,
	NAME,
	QUANTITY
}

@export var sort_mode := SortMode.DISABLED
@export var extra_rows = 1
