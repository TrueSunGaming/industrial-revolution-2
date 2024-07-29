class_name Player extends CharacterBody2D

const SPAWN_POS := Vector2(0, 320)
const inventory_scene: PackedScene = preload("res://scenes/ui/inventory/player/PlayerInventory.tscn")

@export var movement_speed: int
@export_range(0, 1) var rotation_smoothing: float
@export var zoom_ratio: float
@export_range(0, 1) var zoom_smoothing: float

@export var inventory := Inventory.new()

@onready var goal_zoom := float($Camera2D.zoom.x)

func next_frame_zoom(delta: float) -> Vector2:
	var res := lerpf($Camera2D.zoom.x, goal_zoom, 1 - zoom_smoothing ** (delta * 60))
	
	return Vector2(res, res)

func _physics_process(_delta: float) -> void:
	velocity = Input.get_vector("left", "right", "up", "down") * movement_speed
	
	move_and_slide()

func _process(delta: float) -> void:
	rotation = lerp_angle(rotation, global_position.angle_to_point(get_global_mouse_position()), 1 - rotation_smoothing)
	
	$Camera2D.zoom = next_frame_zoom(delta)

func _input(_event: InputEvent) -> void:
	if refs.ui.panel_visible:
		if Input.is_action_just_pressed("inventory"):
			for i in refs.ui.get_node("Panels").get_children(): i.queue_free()
		
		return
	
	if Input.is_action_pressed("zoomin"):
		goal_zoom *= zoom_ratio
		goal_zoom = clampf(goal_zoom, 0.33, 2)
	
	if Input.is_action_pressed("zoomout"):
		goal_zoom /= zoom_ratio
		goal_zoom = clampf(goal_zoom, 0.33, 2)
	
	if Input.is_action_just_pressed("inventory"):
		var node: UIPanel = inventory_scene.instantiate()
		global.show_panel(node)

func _ready() -> void:
	refs.player = self
	global.reset_player_state(SPAWN_POS)
