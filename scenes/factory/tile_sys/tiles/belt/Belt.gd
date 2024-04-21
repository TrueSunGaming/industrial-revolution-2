class_name Belt extends TileEntityNode

enum TurnType {
	UNSET,
	STRAIGHT,
	CW,
	CCW
}

const scenes := {
	TurnType.UNSET: null,
	TurnType.STRAIGHT: preload("res://scenes/factory/tile_sys/tiles/belt/BeltStraight.tscn"),
	TurnType.CW: preload("res://scenes/factory/tile_sys/tiles/belt/BeltTurnCW.tscn"),
	TurnType.CCW: preload("res://scenes/factory/tile_sys/tiles/belt/BeltTurnCCW.tscn")
}

@export var turn_type: TurnType:
	set(val):
		if val == turn_type: return
		turn_type = val
		
		update_data_node()

var scene: PackedScene:
	get:
		return scenes[turn_type]

func update_data_node() -> void:
	if has_node("BeltData"): $BeltData.queue_free()
	
	if not scene: return
	
	add_child(scene.instantiate())

func on_instance_ready(old_instance: TileEntityInstance) -> void:
	if old_instance and old_instance.world_tick.is_connected(update_turn_type): 
		old_instance.world_tick.disconnect(update_turn_type)
	
	instance.world_tick.connect(update_turn_type)
	
	update_turn_type(0)

func update_turn_type(_delta: float) -> void:
	if not instance:
		turn_type = TurnType.UNSET
		return
	
	var bt := instance.backward_tile
	var lt := instance.left_tile
	var rt := instance.right_tile
	
	var incoming_back: bool = bt and bt.rotation == instance.rotation
	var incoming_left: bool = lt and lt.rotation == global.add_deg(instance.rotation, 90)
	var incoming_right: bool = rt and rt.rotation == global.sub_deg(instance.rotation, 90)
	
	if incoming_back or (incoming_left == incoming_right):
		turn_type = TurnType.STRAIGHT
		return
	
	turn_type = TurnType.CCW if incoming_left else TurnType.CW
