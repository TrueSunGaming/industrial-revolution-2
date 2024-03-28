class_name ProceduralFloor extends Sprite2D

@export var tile_size := Vector2(64, 64)
@export var parallax_divisor: float = 1
@export var tile_offset := Vector2()

func _ready() -> void:
	region_enabled = true
	scale = tile_size / texture.get_size()

func _process(delta: float) -> void:
	var cam: Camera2D = get_viewport().get_camera_2d()
	
	if (not cam): return printerr("No camera found for floor rendering")
	
	var next_frame_zoom := cam.zoom
	if (refs.player and cam == refs.player.get_node("Camera2D")): next_frame_zoom = refs.player.next_frame_zoom(delta)
	
	var cam_pos := cam.get_screen_center_position()
	
	global_position = cam_pos
	region_rect.size = get_viewport_rect().size / next_frame_zoom / scale
	region_rect.position = (cam_pos + tile_offset) / scale / parallax_divisor - region_rect.size / 2
