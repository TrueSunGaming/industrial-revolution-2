class_name WorldContainer extends Node2D

@export var world: TileWorld
@export var tick_rate: int

var last_tick: float = -1

func _ready() -> void:
	last_tick = Time.get_unix_time_from_system()

func check_tick() -> void:
	var time := Time.get_unix_time_from_system()
	var diff := time - last_tick
	
	if diff >= 1.0 / float(tick_rate):
		world.process_tick(diff)
		last_tick = time

func _process(delta: float) -> void:
	check_tick()
	
	for i in world.render_buffer: render_tile(i)
	world.render_buffer = []

func render_tile(id: int) -> void:
	var instance := TileEntityInstance.get_tile(id)
	
	if instance.world != world and instance.node_ref: return instance.node_ref.queue_free()
	
	var data := TileEntityData.get_tile_data(instance.data_id)
	instance.node_ref = data.scene.instantiate()
	instance.node_ref.position = instance.position * Vector2(64, 64) - Vector2(32, 32)
	
	add_child(instance.node_ref)
