class_name UIPanel extends PanelContainer

@export var title: String:
	set(val):
		if (val == title): return
		$PanelContent/PanelHeader/Title.text = val

@onready var content := $PanelContent

func _on_close_pressed() -> void:
	queue_free()
