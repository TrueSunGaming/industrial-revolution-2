class_name PlayerInventory extends UIPanel

func _ready() -> void:
	$PanelContent/ScrollContainer/InventoryDisplay.inventory = refs.player.inventory
