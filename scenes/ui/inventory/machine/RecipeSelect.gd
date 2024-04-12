class_name RecipeSelect extends UIPanel

@export var valid_recipe_selector := "*"

@onready var grid: GridContainer = $PanelContent/GridContainer

func _ready() -> void:
	var empty_node := RecipeDisplay.new()
	empty_node.recipe_id = ""
	grid.add_child(empty_node)
	
	empty_node.clicked.connect(func ():
		queue_free()
		closed.emit("")
	)
	
	for i in Recipe.all_valid_recipes(valid_recipe_selector):
		var node := RecipeDisplay.new()
		node.recipe_id = i.id
		grid.add_child(node)
		
		node.clicked.connect(func ():
			queue_free()
			closed.emit(i.id)
		)
