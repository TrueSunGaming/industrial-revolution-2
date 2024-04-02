class_name Portal extends StaticBody2D

static var last_used_portal_position := Vector2()

@export var to_factory := false
@export var destination: PackedScene
@export var destination_name: String:
	get:
		return "Factory" if to_factory else destination_name
	
	set(val):
		if val == destination_name and not to_factory: return
		destination_name = val
		$RichTextLabel.text = "[center][b]Teleport to:[/b]\n[color=lime]" + val

var confirmation_open := false

func _ready() -> void:
	$RichTextLabel.size = Vector2(640, 0)

func _process(_delta: float) -> void:
	$RichTextLabel.scale = Vector2(1, 1) / get_viewport().get_camera_2d().zoom.clamp(Vector2(0, 0), Vector2(1, 1))
	$RichTextLabel.position = $Sprite2D.texture.get_size() * $Sprite2D.scale / 2 - $RichTextLabel.size / 2
	$RichTextLabel.pivot_offset = $RichTextLabel.size / 2

func _input_event(_viewport: Viewport, _event: InputEvent, _shape_idx: int) -> void:
	if confirmation_open: return
	if not Input.is_action_just_released("interact"): return
	
	if not Input.is_physical_key_pressed(KEY_SHIFT):
		confirmation_open = true
		var confirm := await global.confirm(
			"Teleport to " + destination_name + "?",
			"You can disable this confirmation by holding Shift while clicking the portal."
		)
		confirmation_open = false
		if not confirm: return
	
	last_used_portal_position = global_position
	
	if to_factory: return global.unload_world(destination_name, true)
	if not destination: return printerr("Portal destination is null")
	
	global.load_world(destination, destination_name, true)

func _on_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
