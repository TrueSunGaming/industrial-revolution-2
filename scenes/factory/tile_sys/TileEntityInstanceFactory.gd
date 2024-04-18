class_name TileEntityInstanceFactory extends BaseFactory

func _init() -> void:
	register("portal", PortalInstance)
	register("assembler_1", MachineInstance)
	register("belt_1", TileEntityInstance)

func generate(key: String) -> TileEntityInstance:
	var instance: TileEntityInstance = super.generate(key).new()
	if not instance: return null
	
	instance.data_id = key
	
	return instance

func generate_positioned(key: String, position: Vector2, rotation := 0.0) -> TileEntityInstance:
	var instance: TileEntityInstance = generate(key)
	if not instance: return null
	
	instance.position = position
	instance.rotation = rotation
	
	return instance
