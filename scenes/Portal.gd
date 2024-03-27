class_name Portal extends StaticBody2D

@export var destination: PackedScene
@export var destination_name: String:
	set(v):
		$RichTextLabel.text = "[center][b]Teleport to:[/b]\n[color=lime]" + v

func _process(delta: float) -> void:
	$RichTextLabel.scale = Vector2(1, 1) / get_viewport().get_camera_2d().zoom
	$RichTextLabel.pivot_offset = $RichTextLabel.size / 2

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if not Input.is_action_just_released("interact"): return
	
	print("hi")

func _on_mouse_entered() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
