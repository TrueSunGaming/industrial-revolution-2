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

func on_instance_ready() -> void:
	instance.world_tick.connect(update_turn_type)
	instance.click.connect(on_click)

func update_turn_type(_delta: float) -> void:
	if not instance:
		turn_type = TurnType.UNSET
		return
	
	var incoming_back: bool = instance.backward_tile and instance.backward_tile.rotation == instance.rotation
	var incoming_left: bool = instance.left_tile and instance.left_tile.rotation == global.add_deg(instance.rotation, 90)
	var incoming_right: bool = instance.right_tile and instance.right_tile.rotation == global.sub_deg(instance.rotation, 90)
	
	if incoming_back or (incoming_left == incoming_right):
		turn_type = TurnType.STRAIGHT
		return
	
	turn_type = TurnType.CCW if incoming_left else TurnType.CW

func on_click() -> void:
	if not instance: return
	if instance.left_tile: prints(instance.position, "left:", instance.left_tile.position)
	if instance.right_tile: prints(instance.position, "right:", instance.right_tile.position)
