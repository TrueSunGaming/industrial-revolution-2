class_name WorldContainer extends Node2D

@export var world: TileWorld
@export var tick_rate: int

var last_tick: float = -1
var break_progress := 0.0

var hovered_tiles: Array[TileEntityInstance]:
	get:
		return world.tiles.filter(func (v: TileEntityInstance):
			return v.render_rect.has_point(get_local_mouse_position())
		)

var can_place: bool:
	get:
		if refs.ui.panel_visible: return false
		if refs.factory.disabled: return false
		if hovered_tiles.size() > 0: return false
		if not global.item_on_mouse: return false
		return TileWorld.tei_factory.can_generate(global.item_on_mouse.item_id)

var can_interact: bool:
	get:
		if can_place: return false
		if global.item_on_mouse: return false
		return hovered_tiles.size() > 0

var should_reset_break: bool:
	get:
		var hovered := hovered_tiles
		if hovered.size() < 1: return true
		if not hovered[0].tile_data.breakable: return true
		if not Input.is_action_pressed("destroy"): return true
		return false

func _ready() -> void:
	refs.world_container = self
	last_tick = Time.get_unix_time_from_system()

func check_tick() -> void:
	var time := Time.get_unix_time_from_system()
	var diff := time - last_tick
	
	if diff >= 1.0 / float(tick_rate):
		process_tick(diff * float(tick_rate))
		last_tick = time

func process_tick(ticks: float) -> void:
	world.process_tick(ticks)
	
	if should_reset_break:
		break_progress = 0
		return
	
	break_progress += ticks
	
	var tile := hovered_tiles[0]
	
	if break_progress >= tile.tile_data.break_time:
		refs.player.inventory.add_item(ItemStack.new(tile.tile_data.item_id, 1))
		tile.remove_from_world(true)

func _process(delta: float) -> void:
	check_tick()
	
	for i in world.render_buffer: render_tile(i)
	world.render_buffer = []
	
	if hovered_tiles.size() < 1: global.show_hover_indicator(false)
	
	if refs.factory.disabled: return
	
	for i in hovered_tiles:
		global.set_hover_indicator_id(i.id)
		break
	
	check_pipette()
	if Input.is_action_pressed("place") and can_place: return handle_place()

func should_free_tile_node(instance: TileEntityInstance) -> bool:
	if not instance.node_ref: return false
	if instance.world == world: return false
	if instance.world == null: return true
	if instance.node_ref.is_queued_for_deletion(): return false
	
	return instance.node_ref.get_parent() == self

func render_tile(id: int) -> void:
	var instance := TileEntityInstance.get_tile(id)
	if not instance: return
	
	if should_free_tile_node(instance): return instance.clear_node_ref()
	if instance.node_ref: return
	
	var data := TileEntityData.get_tile_data(instance.data_id)
	if not data: return printerr("No TileEntityData found with ID: " + instance.data_id)
	
	instance.node_ref = data.scene.instantiate()
	instance.node_ref.position = instance.render_position
	instance.node_ref.rotation_degrees = instance.rotation
	
	add_child(instance.node_ref)

func handle_hover_click() -> void:
	for i in hovered_tiles:
		i.on_click()
		i.click.emit()

func handle_interact() -> void:
	if hovered_tiles.size() > 0: handle_hover_click()

func handle_place() -> void:
	world.place_held_item()

func handle_pipette() -> void:
	var held_item_id = global.item_on_mouse.item_id if global.item_on_mouse else ""
	
	global.clear_hand()
	
	if hovered_tiles.size() < 1: return
	
	for i in hovered_tiles:
		if not i.tile_data.item_id: continue
		if i.tile_data.item_id == held_item_id: continue
		
		var count := refs.player.inventory.get_item_count(i.tile_data.item_id)
		if count < 1: continue
		
		global.item_on_mouse = ItemStack.new(i.tile_data.item_id, count)
		global.item_on_mouse_original_inventory = refs.player.inventory
		
		refs.player.inventory.take_item(global.item_on_mouse)
		
		break

func check_pipette() -> void:
	if refs.ui.panel_visible: return
	if refs.factory.disabled: return
	if Input.is_action_just_pressed("pipette"): handle_pipette()

func _input(event: InputEvent) -> void:
	if refs.ui.panel_visible: return
	if refs.factory.disabled: return
	
	if Input.is_action_just_pressed("interact") and can_interact: handle_interact()
