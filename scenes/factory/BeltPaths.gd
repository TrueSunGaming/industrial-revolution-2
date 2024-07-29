class_name BeltPaths extends Node2D

var paths: Array[BeltPath] = []
var searched: Array[Vector2i] = []

func _ready() -> void:
	refs.belt_paths = self

func generate_paths(instances: Array[TileEntityInstance]) -> void:
	for i in instances:
		if searched.has(Vector2i(i.position)): continue
		
		evaluate_instance(i)
		searched.push_back(Vector2i(i.position))

# TODO
func can_add_to_path(pos: Vector2i, connecting_to: Vector2i) -> bool:
	assert(false)
	
	return false

func evaluate_instance(instance: TileEntityInstance) -> void:
	pass
