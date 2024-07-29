class_name BeltPathSide extends RefCounted

const TILE_SIZE := 64.0
const STRAIGHT_LENGTH := TILE_SIZE
const SIDE_OFFSET := 16.0
const INNER_CURVE_LENGTH := PI / 2.0 * SIDE_OFFSET
const OUTER_CURVE_LENGTH := PI / 2.0 * (TILE_SIZE - SIDE_OFFSET)

var speed: float
var minimum_spacing: float
var segments: Array[float] = [INF]
var items: Array[String] = []
var length: float

var has_segments: bool:
	get:
		return segments.size() > 1

var last: float:
	get:
		return distance_at(segments.size() - 2)

var current_moving_index: int:
	get:
		for i in segments.size():
			if segments[i] > (minimum_spacing if i > 0 else 0): return i
		
		return -1

var current_minimum_spacing: float:
	get:
		return minimum_spacing if current_moving_index > 0 else 0

var first_cannot_move: bool:
	get:
		return segments[0] <= 0

func _init(move_speed: float, min_spacing: float = 0, max_length := INF) -> void:
	speed = move_speed
	minimum_spacing = min_spacing
	length = max_length

func move(distance: float) -> void:
	if distance <= 0: return
	if not has_segments: return
	
	print(current_moving_index)
	
	var moved: float = min(segments[current_moving_index] - current_minimum_spacing, distance)
	segments[current_moving_index] -= moved
	
	if moved < distance: move(distance - moved)

func update(delta: float) -> void:
	move(speed * delta)

func distance_at(index: int) -> float:
	if index < 0: return 0
	return segments.slice(0, min(index + 1, segments.size())).reduce(func (t, v): return t + v, 0)

func last_index_until(position: float) -> int:
	for i in segments.size() + 1:
		if distance_at(i) >= position: return i - 1
	
	return segments.size() - 1

func next_index_from(position: float) -> int:
	for i in segments.size():
		if distance_at(i) >= position: return i
	
	return -1

func add_item(position: float, item_id: String) -> bool:
	if position < 0: return false
	if position > length - minimum_spacing: return false
	
	for i in segments.size():
		var next := distance_at(i)
		if next <= position: continue
		
		var prev: float = distance_at(i - 1)
		
		if next - position < minimum_spacing: continue
		if i > 0 and abs(prev - position) < minimum_spacing: continue
		
		var inserted_length := position - prev
		
		segments[i] -= inserted_length
		segments.insert(i, inserted_length)
		items.insert(i, item_id)
		
		return true
	
	return false

func add_item_back(item_id: String) -> bool:
	return add_item(length - minimum_spacing, item_id)

func remove_item(index: int) -> void:
	if index < 0: return
	if index >= segments.size() - 1: return
	
	segments[index + 1] += segments[index]
	segments.remove_at(index)
	items.remove_at(index)

func remove_front() -> void:
	remove_item(0)

func slice(start: float, end: float) -> BeltPathSide:
	var res := BeltPathSide.new(speed, minimum_spacing)
	
	var first := next_index_from(start)
	var last := last_index_until(end)
	
	var first_dist := distance_at(first)
	
	if first > last or first_dist > end or distance_at(last) < start: return res
	
	res.items = items.slice(first, last + 1)
	res.segments = segments.slice(first, last + 1)
	res.segments[0] = first_dist - start
	
	return res
