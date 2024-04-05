class_name RecipeIngredient extends Resource

@export var selector := ""
@export var count := 0

func valid_item(item: ItemStack) -> bool:
	return item.item.satisfies_selector(selector)
