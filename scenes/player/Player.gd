class_name Player extends CharacterBody2D

const SPAWN_POS := Vector2(0, 320)

@export var movement_speed: int
@export_range(0, 1) var rotation_smoothing: float
@export var zoom_ratio: float
@export_range(0, 1) var zoom_smoothing: float

@onready var goal_zoom := float($Camera2D.zoom.x)

func next_frame_zoom(delta: float) -> Vector2:
	var res := lerpf($Camera2D.zoom.x, goal_zoom, 1 - zoom_smoothing ** (delta * 60))
	
	return Vector2(res, res)

func _physics_process(delta: float) -> void:
	velocity = Input.get_vector("left", "right", "up", "down") * movement_speed
	
	move_and_slide()

func _process(delta: float) -> void:
	rotation = lerp_angle(rotation, global_position.angle_to_point(get_global_mouse_position()), 1 - rotation_smoothing)
	
	$Camera2D.zoom = next_frame_zoom(delta)

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("zoomin"):
		goal_zoom *= zoom_ratio
	
	if Input.is_action_pressed("zoomout"):
		goal_zoom /= zoom_ratio
	
	goal_zoom = clampf(goal_zoom, 0.33, 2)

func _ready() -> void:
	refs.player = self
	global.reset_player_state(SPAWN_POS)
