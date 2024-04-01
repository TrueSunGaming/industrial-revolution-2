class_name Inventory extends Resource

enum AllowType {
	ITEM_ONLY,
	FLUID_ONLY,
	ITEM_AND_FLUID
}

@export var items: Array[ItemStack]:
	set(val):
		items = val
		simplify()

@export var whitelist: Array[String] = []
@export var blacklist: Array[String] = []
@export var limits: Array[ItemStack] = []
@export var allow: AllowType

var needs_simplify: bool:
	get:
		var found: Array[String] = []
		
		for i in items:
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

func _init(items: Array[ItemStack] = [], allow := AllowType.ITEM_ONLY) -> void:
	self.items = items
	self.allow = allow

func simplify() -> void:
	if not needs_simplify: return
	
	items = []
	for i in counts.keys():
		if counts[i] > 0: items.push_back(ItemStack.new(i, counts[i]))

func item_allowed(item: Item) -> bool:
	if allow == AllowType.ITEM_ONLY: return item.type == Item.Type.ITEM
	if allow == AllowType.FLUID_ONLY: return item.type == Item.Type.FLUID
	return true

func has_item(item_id: String) -> bool:
	return items.filter(func (v: ItemStack): return v.item_id == item_id).size() > 0

func has_atleast(item: ItemStack) -> bool:
	return get_item_count(item.item_id) > item.count

func has_atleast_all(items: Array[ItemStack]) -> bool:
	return items.reduce(func (t: bool, v: ItemStack): return t and has_atleast(v))

func get_item_count(item_id: String) -> int:
	return counts.get(item_id, 0)

func add_item(item: ItemStack) -> int:
	if blacklist.has(item.item_id) or (whitelist.size() > 0 and not whitelist.has(item.item_id)): return 0
	
	var limit_stack: Array[ItemStack] = limits.filter(func (v: ItemStack): return v.item_id == item.item_id)
	var max_allowed: int = limit_stack[0].count if limit_stack.size() > 0 else -1
	var count_added: int = min(item.count, max_allowed - get_item_count(item.item_id)) if max_allowed >= 0 else item.count
	
	if not has_item(item.item_id):
		items.push_back(ItemStack.new(item.item_id, count_added))
		return count_added
	
	simplify()
	
	items.filter(func (v: ItemStack): return v.item_id == item.item_id)[0].count += count_added
	
	return count_added

func add_items(items: Array[ItemStack]) -> Dictionary:
	var res := {}
	
	for i in items:
		if res.has(i.item_id): res[i.item_id] += add_item(i)
		else: res[i.item_id] = add_item(i)
	
	return res

func take_item(item: ItemStack) -> bool:
	if not has_atleast(item): return false
	
	items.filter(func (v: ItemStack): return v.item_id == item.item_id)[0].count -= item.count
	
	return true

func take_items(items: Array[ItemStack]) -> bool:
	if not has_atleast_all(items): return false
	
	for i in items: take_item(i)
	
	return true

func perform_recipe(recipe: Recipe, output_inventory := self) -> bool:
	if not take_items(recipe.ingredients): return false
	
	output_inventory.add_items(recipe.result)
	
	return true

func perform_recipe_id(id: String, output_inventory := self) -> bool:
	var recipe: Recipe = Recipe.get_recipe(id)
	
	if not recipe:
		printerr("No recipe found with id " + id)
		return false
	
	return perform_recipe(recipe, output_inventory)
