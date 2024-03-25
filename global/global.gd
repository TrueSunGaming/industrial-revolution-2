extends Node

func show_panel(panel: Control) -> void:
	if (not refs.ui): return print("No UI reference to add panel to")
	
	refs.ui.show_panel(panel)
