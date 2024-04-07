class_name RecipeSelect extends UIPanel

@onready var grid: GridContainer = $PanelContent/GridContainer

func _ready() -> void:
	var empty_node := RecipeDisplay.new()
	empty_node.recipe_id = ""
	grid.add_child(empty_node)
	
	empty_node.clicked.connect(func ():
		queue_free()
		closed.emit("")
	)
	
	for i in Recipe.list.keys():
		var node := RecipeDisplay.new()
		node.recipe_id = i
		grid.add_child(node)
		
		node.clicked.connect(func ():
			queue_free()
			closed.emit(i)
		)
