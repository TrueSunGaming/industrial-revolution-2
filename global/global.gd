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

func load_world(scene: PackedScene) -> void:
	if not refs.main: return printerr("No main reference to load world")
	
	var instance: Node2D = scene.instantiate()
	instance.name = "World"
	
	unload_world()
	refs.main.get_node("Environment").add_child(instance)

func unload_world(to_factory := false) -> void:
	if not refs.main: return printerr("No main reference to unload world")
	
	var old_world: Node2D = refs.main.get_node_or_null("Environment/World")
	if old_world: old_world.queue_free()
	
	refs.factory.disabled = not to_factory
	
	reset_player_state(to_factory)

func reset_player_state(to_factory := false) -> void:
	if refs.player: refs.player.global_position = Vector2(0, 320) if to_factory else Vector2()

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
