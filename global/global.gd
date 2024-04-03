extends Node

const alert_scene: PackedScene = preload("res://scenes/ui/Alert.tscn")
const confirm_scene: PackedScene = preload("res://scenes/ui/Confirm.tscn")
 
class ConfirmResult extends RefCounted:
	signal closed(result)
	
	func _init(close: BaseButton, cancel: BaseButton, okay: BaseButton) -> void:
		for i: BaseButton in [close, cancel]:
			i.connect("pressed", func ():
				closed.emit(false)
			)
		
		okay.connect("pressed", func ():
			closed.emit(true)
		)

func show_panel(panel: UIPanel) -> void:
	if (not refs.ui): return printerr("No UI reference to add panel to")
	
	refs.ui.show_panel(panel)

func alert(title: String, msg: String, wait := false) -> void:
	var panel: UIPanel = alert_scene.instantiate()
	
	panel.get_node("PanelContent/Label").text = msg
	panel.title = title
	
	show_panel(panel)
	
	if wait: await panel.closed

func confirm(title: String, msg: String) -> bool:
	var panel: Confirm = confirm_scene.instantiate()
	
	panel.get_node("PanelContent/Label").text = msg
	
	panel.title = title
	
	show_panel(panel)
	
	return await panel.closed

func load_world(scene: PackedScene, destination: String, using_portal := false) -> void:
	if not refs.main: return printerr("No main reference to load world")
	
	var instance: Node2D = scene.instantiate()
	instance.name = "World"
	
	unload_world(destination, using_portal)
	refs.main.get_node("Environment").add_child(instance)

func unload_world(destination: String, using_portal := false) -> void:
	if not refs.main: return printerr("No main reference to unload world")
	
	var old_world: Node2D = refs.main.get_node_or_null("Environment/World")
	if old_world: old_world.queue_free()
	
	refs.factory.disabled = destination != "Factory"
	
	match destination:
		"Factory":
			if not using_portal or not refs.player: return reset_player_state()
			reset_player_state(refs.player.global_position)
		
		"Hub":
			if not using_portal or not refs.player: return reset_player_state()
			
			var portal_pos := Portal.last_used_portal_position
			
			if refs.player.global_position.distance_squared_to(portal_pos) <= 541696:
				return reset_player_state(refs.player.global_position)
			
			reset_player_state(portal_pos + portal_pos.direction_to(refs.player.global_position) * 500)

func reset_player_state(pos := Vector2()) -> void:
	if refs.player: refs.player.global_position = pos

func get_all_children(node: Node) -> Array[Node]:
	var res: Array[Node] = []
	
	for i in node.get_children():
		res.push_back(i)
		res.append_array(get_all_children(i))
	
	return res

func set_background_sound(sound: AudioStream) -> void:
	refs.main.get_node("AudioStreamPlayer").stream = sound

func set_background_sound_bus(bus: String) -> void:
	refs.main.get_node("AudioStreamPlayer").bus = bus

func clamp_deg(val: float) -> float:
	return fmod(val, 360) if val >= 0 else 360 + fmod(val, 360)

func add_deg(a: float, b: float) -> float:
	return clamp_deg(a + b)

func sub_deg(a: float, b: float) -> float:
	return clamp_deg(a - b)

func center_rotation_displacement(rect: Rect2, deg: float) -> Vector2:
	return (rect.size.rotated(deg_to_rad(deg)) - rect.size) / 2
