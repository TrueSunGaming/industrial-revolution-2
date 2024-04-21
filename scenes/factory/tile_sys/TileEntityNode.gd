class_name TileEntityNode extends Node2D

var instance: TileEntityInstance:
	set(val):
		if val == instance: return
		
		var old := instance
		instance = val
		
		if val: on_instance_ready(old)

func on_instance_ready(_old_instance: TileEntityInstance) -> void:
	pass
