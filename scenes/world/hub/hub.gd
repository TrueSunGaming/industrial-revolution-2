extends Node2D

var hovered: Array[Hoverable] = []

enum Hoverable {
	PORTAL
}

const hoverable_rects: Dictionary = {
	Hoverable.PORTAL: Rect2(-160, -160, 320, 320)
}

func _on_portal_mouse_entered() -> void:
	if not hovered.has(Hoverable.PORTAL): hovered.push_back(Hoverable.PORTAL)

func _on_portal_mouse_exited() -> void:
	hovered.erase(Hoverable.PORTAL)

func _process(delta: float) -> void:
	global.show_hover_indicator(hovered.size() > 0 and hoverable_rects.has(hovered[0]))
	if hovered.size() > 0: global.set_hover_indicator_rect(hoverable_rects.get(hovered[0]))
