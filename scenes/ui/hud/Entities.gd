extends Label

func _process(_delta: float) -> void:
	text = "Entities: " + str(refs.world_container.world.tiles.size()) if refs.world_container and refs.world_container.world else "No world"
