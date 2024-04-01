class_name UIPanel extends PanelContainer

signal closed

@export var title: String:
	set(val):
		if (val == title): return
		title = val
		$PanelContent/PanelHeader/Title.text = val

func _on_close_pressed() -> void:
	queue_free()
	closed.emit(false)
