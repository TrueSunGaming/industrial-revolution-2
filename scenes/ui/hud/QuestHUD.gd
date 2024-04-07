class_name QuestHUD extends PanelContainer

@export var color_smoothing := 0.8

var col := Vector4(1, 1, 1, 1)
var col_goal := col

func _ready() -> void:
	refs.quest_hud = self

func _process(delta: float) -> void:
	col = col.lerp(col_goal, 1 - color_smoothing ** (delta * 30))
	
	$Content.material.set_shader_parameter("modulate", col)

func _on_mouse_entered() -> void:
	col_goal = Vector4(1, 1, 0.7, 1)

func _on_mouse_exited() -> void:
	col_goal = Vector4(1, 1, 1, 1)
