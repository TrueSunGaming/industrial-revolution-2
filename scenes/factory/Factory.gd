class_name Factory extends Node2D

@export var disabled := false:
	set(val):
		if val == disabled: return
		disabled = val
		
		visible = not val
		
		for i in global.get_all_children(self):
			if not (i is CollisionShape2D or i is CollisionPolygon2D): continue
			
			i.disabled = val

func _ready() -> void:
	refs.factory = self
	
	var bps := BeltPathSide.new(5, 5)
	bps.add_item(20, "test 1")
	bps.add_item(30, "test 2")
	bps.add_item(25, "test 3")
	prints(bps.segments, bps.items)
