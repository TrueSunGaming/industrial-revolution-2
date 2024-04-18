class_name TileEntityNode extends Node2D

var instance: TileEntityInstance:
	set(val):
		if val == instance: return
		instance = val
		
		if val: on_instance_ready()

func on_instance_ready() -> void:
	pass
