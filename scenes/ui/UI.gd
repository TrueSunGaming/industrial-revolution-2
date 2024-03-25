class_name UI extends CanvasLayer

var panel_visible: bool:
	get: return $Panels.get_child_count() > 0

func _ready() -> void:
	refs.ui = self

func show_panel(panel: Control) -> void:
	$Panels.add_child(panel)
