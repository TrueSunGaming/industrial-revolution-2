class_name WorldContainer extends Node2D

@export var world: TileWorld
@export var tick_rate: int

var last_tick: float = -1

var hovered_tiles: Array[TileEntityInstance]:
	get:
		return world.tiles.filter(func (v: TileEntityInstance):
			return v.render_rect.has_point(get_local_mouse_position())
		)

func _ready() -> void:
	refs.world_container = self
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
	
	if refs.factory.visible:
		for i in hovered_tiles:
			global.set_hover_indicator_id(i.id)
			break
	
	if hovered_tiles.size() < 1: global.show_hover_indicator(false)

func should_free_tile_node(instance: TileEntityInstance) -> bool:
	if not instance.node_ref: return false
	if instance.world == world: return false
	if instance.world == null: return true
	
	return instance.node_ref.get_parent() == self

func render_tile(id: int) -> void:
	var instance := TileEntityInstance.get_tile(id)
	
	if should_free_tile_node(instance): return instance.node_ref.queue_free()
	if instance.node_ref: return
	
	var data := TileEntityData.get_tile_data(instance.data_id)
	if not data: return printerr("No TileEntityData found with ID: " + instance.data_id)
	
	instance.node_ref = data.scene.instantiate()
	instance.node_ref.position = instance.render_position
	instance.node_ref.rotation_degrees = instance.rotation
	
	add_child(instance.node_ref)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_released("interact"):
		for i in hovered_tiles:
			i.on_click()
