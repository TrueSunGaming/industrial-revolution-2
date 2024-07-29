class_name BeltPath extends RefCounted

static var cache := {}

enum BeltSide {
	LEFT,
	RIGHT
}

var left: BeltPathSide
var right: BeltPathSide
var positions: Array[Vector2i] = []:
	set(val):
		if val == positions: return
		
		for i in positions:
			if not val.has(i): cache.erase(i)
		
		for i in val.size():
			if not is_cached_at(val[i]) or path_at(val[i]) != self: cache[val[i]] = [self, i]
		
		positions = val

var rotations: Array[float] = []:
	set(val):
		if val == rotations: return
		rotations = val
		
		update_lengths()

var turn_types: Array[Belt.TurnType] = []

func _init(speed: float, minimum_spacing: float = 0) -> void:
	left = BeltPathSide.new(speed, minimum_spacing)
	right = BeltPathSide.new(speed, minimum_spacing)

func update(delta: float) -> void:
	left.update(delta)
	right.update(delta)

func get_side(side: BeltSide) -> BeltPathSide:
	return left if side == BeltSide.LEFT else right

func add_item(item_id: String, side: BeltSide, position: float) -> bool:
	return get_side(side).add_item(position, item_id)

func add_item_back(item_id: String, side: BeltSide) -> bool:
	return get_side(side).add_item_back(item_id)

func update_turn_types() -> void:
	turn_types = Belt.generate_turn_types(positions, rotations)

func calculate_length(side: BeltSide, index := -1) -> float:
	var res := 0.0
	
	for i in min(turn_types.size(), index) if index >= 0 else turn_types.size(): match turn_types[i]:
		Belt.TurnType.STRAIGHT, Belt.TurnType.UNSET: res += BeltPathSide.STRAIGHT_LENGTH
		Belt.TurnType.CW when side == BeltSide.LEFT: res += BeltPathSide.OUTER_CURVE_LENGTH
		Belt.TurnType.CW when side == BeltSide.RIGHT: res += BeltPathSide.INNER_CURVE_LENGTH
		Belt.TurnType.CCW when side == BeltSide.LEFT: res += BeltPathSide.INNER_CURVE_LENGTH
		Belt.TurnType.CCW when side == BeltSide.RIGHT: res += BeltPathSide.OUTER_CURVE_LENGTH
	
	return res

func update_length(side: BeltSide) -> void:
	get_side(side).length = calculate_length(side)

func update_lengths(update_types := true) -> void:
	if update_types: update_turn_types()
	
	update_length(BeltSide.LEFT)
	update_length(BeltSide.RIGHT)

func distance_at(side: BeltSide, index: int) -> float:
	return get_side(side).distance_at(index)

static func is_cached_at(position: Vector2i) -> bool:
	return cache.has(position)

static func cached_at(position: Vector2i) -> Array[Variant]:
	var cached: Variant = cache.get(position)
	assert(cached is Array, "No cached value found at position " + str(position))
	
	return cached

static func path_at(position: Vector2i) -> BeltPath:
	return cached_at(position)[0]

static func index_of(position: Vector2i) -> int:
	return cached_at(position)[1]

static func rotation_at(position: Vector2i) -> float:
	var cached := cached_at(position)
	
	return cached[0].rotations[cached[1]]

static func turn_type_at(position: Vector2i) -> float:
	var cached := cached_at(position)
	
	return cached[0].turn_types[cached[1]]

func attempt_transfer(side: BeltSide) -> bool:
	assert(positions.size() == rotations.size(), "Position and rotation arrays must be of equal length")
	
	var bp_side := get_side(side)
	if bp_side.segments[0] > 0: return false
	
	var forward_pos := positions[-1]
	var last_rotation := rotations[-1]
	
	match last_rotation:
		0: forward_pos += Vector2i(1, 0)
		90: forward_pos += Vector2i(0, 1)
		180: forward_pos += Vector2i(-1, 0)
		270: forward_pos += Vector2i(0, -1)
	
	if not is_cached_at(forward_pos): return false
	
	var forward := path_at(forward_pos)
	var index := index_of(forward_pos)
	var forward_rotation := global.clamp_deg(forward.rotations[index])
	
	if forward_rotation == global.add_deg(last_rotation, 180): return false
	var transfer_side := BeltSide.LEFT if forward_rotation == global.sub_deg(last_rotation, 90) else BeltSide.RIGHT
	
	var distance := forward.calculate_length(transfer_side, index - 1)
	var offset := BeltPathSide.SIDE_OFFSET if side == transfer_side else (BeltPathSide.STRAIGHT_LENGTH - BeltPathSide.SIDE_OFFSET)
	
	if not forward.add_item(bp_side.items[0], transfer_side, distance + offset): return false
	bp_side.remove_item(0)
	
	return true

func side_distance_start(side: BeltSide, index: int) -> float:
	return calculate_length(side, index - 1) if index > 0 else 0

func items_on_side_at(side: BeltSide, index: int) -> Array[String]:
	var bps := get_side(side)
	
	var first := bps.next_index_from(side_distance_start(side, index))
	var last := bps.last_index_until(calculate_length(side, index))
	
	return bps.items.slice(first, last + 1)

func items_at(index: int) -> Array[String]:
	var items := items_on_side_at(BeltSide.LEFT, index)
	items.append_array(items_on_side_at(BeltSide.RIGHT, index))
	
	return items

func remove_belt(index: int) -> Array[String]:
	var items := items_at(index)
	
	var new_bp := BeltPath.new(left.speed, left.minimum_spacing)
	new_bp.positions = positions.slice(index + 1)
	new_bp.rotations = rotations.slice(index + 1)
	
	if path_at(positions[index]) == self: cache.erase(positions[index])
	
	positions.resize(index)
	rotations.resize(index)
	
	return items

static func remove_belt_at(position: Vector2i) -> Array[String]:
	if not is_cached_at(position): return []
	
	return path_at(position).remove_belt(index_of(position))
