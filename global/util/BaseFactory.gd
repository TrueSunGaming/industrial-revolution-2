class_name BaseFactory extends RefCounted

var lookup := {}

func generate(key: String) -> Variant:
	return lookup.get(key)

func register(key: String, value: Variant) -> void:
	lookup[key] = value

func can_generate(key: String) -> bool:
	return lookup.has(key)
