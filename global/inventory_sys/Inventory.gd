class_name Inventory extends Resource

signal items_changed
signal filters_changed

enum AllowType {
	ITEM_ONLY,
	FLUID_ONLY,
	ITEM_AND_FLUID
}

@export var items: Array[ItemStack]:
	set(val):
		items = val
		simplify(true)
		items_changed.emit()

@export var whitelist: Array[String] = []:
	set(val):
		whitelist = val
		filters_changed.emit()

@export var blacklist: Array[String] = []:
	set(val):
		blacklist = val
		filters_changed.emit()

@export var limits: Array[ItemStack] = []:
	set(val):
		limits = val
		filters_changed.emit()

@export var allow: AllowType:
	set(val):
		allow = val
		filters_changed.emit()

var needs_simplify: bool:
	get:
		var found: Array[String] = []
		
		for i in items:
			if i.count == 0: return true
			if found.has(i.item_id): return true
			found.push_back(i.item_id)
		
		return false

var counts: Dictionary:
	get:
		var res := {}
		for i in items:
			if res.has(i.item_id): res[i.item_id] += i.count
			else: res[i.item_id] = i.count
		
		return res

func simplify(silent := false) -> void:
	if not needs_simplify: return
	
	items = []
	for i in counts.keys():
		if counts[i] > 0: items.push_back(ItemStack.new(i, counts[i]))
	
	if not silent: items_changed.emit()

func item_allowed(item: Item) -> bool:
	if allow == AllowType.ITEM_ONLY: return item.type == Item.Type.ITEM
	if allow == AllowType.FLUID_ONLY: return item.type == Item.Type.FLUID
	return true

func has_item(item_id: String) -> bool:
	return items.filter(func (v: ItemStack): return v.item_id == item_id).size() > 0

func has_atleast(item: ItemStack) -> bool:
	return get_item_count(item.item_id) >= item.count

func has_atleast_ingredient(ingredient: RecipeIngredient) -> bool:
	return get_selector_count(ingredient.selector) >= ingredient.count

func has_atleast_all(stacks: Array[ItemStack]) -> bool:
	return stacks.reduce(func (t: bool, v: ItemStack): return t and has_atleast(v), true)

func has_atleast_all_ingredients(ingredients: Array[RecipeIngredient]) -> bool:
	return ingredients.reduce(func (t: bool, v: RecipeIngredient): return t and has_atleast_ingredient(v), true)

func get_item_count(item_id: String) -> int:
	return counts.get(item_id, 0)

func filter_items(selector: String) -> Array[ItemStack]:
	return items.filter(func (v: ItemStack): return v.item.satisfies_selector(selector))

func get_selector_count(selector: String) -> int:
	return counts.keys().reduce(func (t: int, v: String): 
		return t + (counts.get(v, 0) if Item.id_satisfies_selector(v, selector) else 0),
		0
	)

func add_item(item: ItemStack, silent := false) -> int:
	if blacklist.has(item.item_id) or (whitelist.size() > 0 and not whitelist.has(item.item_id)): return 0
	
	var limit_stack: Array[ItemStack] = limits.filter(func (v: ItemStack): return v.item_id == item.item_id)
	var max_allowed: int = limit_stack[0].count if limit_stack.size() > 0 else -1
	var count_added: int = min(item.count, max_allowed - get_item_count(item.item_id)) if max_allowed >= 0 else item.count
	
	if not has_item(item.item_id):
		items.push_back(ItemStack.new(item.item_id, count_added))
		if not silent: items_changed.emit()
		return count_added
	
	simplify(true)
	
	items.filter(func (v: ItemStack): return v.item_id == item.item_id)[0].count += count_added
	
	simplify(true)
	
	if not silent: items_changed.emit()
	return count_added

func add_items(items: Array[ItemStack], silent := false) -> Dictionary:
	var res := {}
	
	for i in items:
		if res.has(i.item_id): res[i.item_id] += add_item(i, true)
		else: res[i.item_id] = add_item(i, true)
	
	if not silent: items_changed.emit()
	return res

func take_item(item: ItemStack, silent := false) -> bool:
	if not has_atleast(item): return false
	
	simplify(true)
	
	items.filter(func (v: ItemStack): return v.item_id == item.item_id)[0].count -= item.count
	
	simplify(true)
	
	if not silent: items_changed.emit()
	return true

func take_ingredient(ingredient: RecipeIngredient, silent := false) -> bool:
	if not has_atleast_ingredient(ingredient): return false
	
	var stacks := filter_items(ingredient.selector)
	
	var remaining := ingredient.count
	for i in stacks:
		var taken: int = min(i.count, remaining)
		take_item(ItemStack.new(i.item_id, taken), true)
		remaining -= taken
		if remaining < 1: break
	
	if not silent: items_changed.emit()
	return true

func take_items(stacks: Array[ItemStack], silent := false) -> bool:
	if not has_atleast_all(stacks): return false
	
	for i in stacks: take_item(i, true)
	
	if not silent: items_changed.emit()
	return true

func take_ingredients(ingredients: Array[RecipeIngredient], silent := false) -> bool:
	if not has_atleast_all_ingredients(ingredients): return false
	
	for i in ingredients: take_ingredient(i, true)
	
	if not silent: items_changed.emit()
	return true

func perform_recipe(recipe: Recipe, output_inventory := self, silent := false) -> bool:
	if not has_atleast_all_ingredients(recipe.ingredients): return false
	
	take_ingredients(recipe.ingredients, true)
	output_inventory.add_items(recipe.result, true)
	
	if not silent:
		items_changed.emit()
		output_inventory.items_changed.emit()
	
	return true

func perform_recipe_id(id: String, output_inventory := self, silent := false) -> bool:
	var recipe: Recipe = Recipe.get_recipe(id)
	
	if not recipe:
		printerr("No recipe found with id " + id)
		return false
	
	return perform_recipe(recipe, output_inventory, silent)
