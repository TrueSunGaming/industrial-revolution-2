class_name Confirm extends UIPanel

func _on_okay_pressed() -> void:
	queue_free()
	closed.emit(true)

func _on_cancel_pressed() -> void:
	queue_free()
	closed.emit(false)
