class_name ProceduralFloor extends Sprite2D

@export var tile_size := Vector2(64, 64)
@export var parallax_divisor: float = 1
@export var tile_offset := Vector2()

func _ready() -> void:
	region_enabled = true
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED

func _process(delta: float) -> void:
	var cam: Camera2D = get_viewport().get_camera_2d()
	
	if (not cam): return printerr("No camera found for floor rendering")
	
	var next_frame_zoom := cam.zoom
	if (refs.player and cam == refs.player.get_node("Camera2D")): next_frame_zoom = refs.player.next_frame_zoom(delta)
	
	var cam_pos := cam.get_screen_center_position()
	
	var parallax_scaling := Vector2(
		next_frame_zoom.x ** (1 - 1 / parallax_divisor),
		next_frame_zoom.y ** (1 - 1 / parallax_divisor)
	)
	
	scale = tile_size / texture.get_size() / parallax_scaling
	global_position = cam_pos
	region_rect.size = 3 * get_viewport_rect().size / next_frame_zoom / scale
	region_rect.position = (cam_pos + tile_offset) / scale / parallax_divisor / parallax_scaling - region_rect.size / 2
