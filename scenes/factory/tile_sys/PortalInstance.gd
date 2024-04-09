class_name PortalInstance extends TileEntityInstance

@export var destination: PackedScene:
	set(val):
		if val == destination: return
		destination = val
		
		update_destination()

@export var destination_name: String:
	set(val):
		if val == destination_name: return
		destination_name = val
		
		update_destination()
 
func on_click() -> void:
	node_ref.get_node("Portal").teleport()

func on_node_ref_change() -> void:
	update_destination()

func update_destination() -> void:
	if not node_ref: return
	
	node_ref.get_node("Portal").destination = destination
	node_ref.get_node("Portal").destination_name = destination_name
