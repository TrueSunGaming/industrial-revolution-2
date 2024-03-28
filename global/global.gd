extends Node

var ui_panel_scene: PackedScene = preload("res://scenes/ui/UIPanel.tscn")
var ui_panel_style: StyleBoxFlat = preload("res://scenes/ui/UIPanel_stylebox.tres")
var roboto: Font = preload("res://global/Roboto-Regular.ttf")

class ConfirmResult extends Object:
	signal closed(result)
	
	func _init(close: BaseButton, cancel: BaseButton, okay: BaseButton) -> void:
		for i: BaseButton in [close, cancel]:
			i.connect("pressed", func ():
				closed.emit(false)
			)
		
		okay.connect("pressed", func ():
			closed.emit(true)
		)

func show_panel(panel: UIPanel) -> void:
	if (not refs.ui): return printerr("No UI reference to add panel to")
	
	refs.ui.show_panel(panel)

func alert(title: String, msg: String, wait := false) -> void:
	var panel: UIPanel = ui_panel_scene.instantiate()
	
	var text := Label.new()
	text.text = msg
	text.add_theme_font_override("font", roboto)
	
	panel.title = title
	panel.get_node("PanelContent").add_child(text)
	
	show_panel(panel)
	
	if wait: await panel.get_node("PanelContent/PanelHeader/HBoxContainer/Close").pressed

func confirm(title: String, msg: String) -> bool:
	var panel: UIPanel = ui_panel_scene.instantiate()
	
	var text := Label.new()
	text.text = msg
	text.add_theme_font_override("font", roboto)
	
	var hbox := HBoxContainer.new()
	
	var ok := Button.new()
	ok.text = "Okay"
	
	var cancel := Button.new()
	cancel.text = "Cancel"
	
	for i: Button in [ok, cancel]:
		for j in ["normal", "hover", "pressed"]: i.add_theme_stylebox_override(j, ui_panel_style)
		i.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		i.connect("pressed", func():
			panel.queue_free()
		)
		
		hbox.add_child(i)
	
	panel.title = title
	
	panel.get_node("PanelContent").add_child(text)
	panel.get_node("PanelContent").add_child(hbox)
	
	show_panel(panel)
	
	return await ConfirmResult.new(panel.get_node("PanelContent/PanelHeader/HBoxContainer/Close"), cancel, ok).closed
