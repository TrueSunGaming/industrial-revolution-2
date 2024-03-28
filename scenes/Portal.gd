class_name Portal extends StaticBody2D

@export var destination: PackedScene
@export var destination_name: String:
	set(v):
		$RichTextLabel.text = "[center][b]Teleport to:[/b]\n[color=lime]" + v

func _ready() -> void:
	$RichTextLabel.size = Vector2(640, 0)

func _process(delta: float) -> void:
	$RichTextLabel.scale = Vector2(0.33, 0.33) / get_viewport().get_camera_2d().zoom.clamp(Vector2(0, 0), Vector2(1, 1))
	$RichTextLabel.position = -$RichTextLabel.size / 2
	$RichTextLabel.pivot_offset = $RichTextLabel.size / 2

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if not Input.is_action_just_released("interact"): return
	
	print(await global.confirm("Portal", "Portal clicked"))
	
	if not destination: return printerr("Portal destination is null")
	
	get_tree().change_scene_to_packed(destination)

func _on_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
