class_name Item extends Resource

enum Type {
	ITEM,
	FLUID
}

static var list := {}

@export var name: String
@export var id: String
@export var texture: Texture2D
@export var description: String
@export var type: Type

func _init(id: String, name: String, texture: Texture2D, description := "", type := Type.ITEM) -> void:
	self.id = id
	self.name = name
	self.texture = texture
	self.description = description
	self.type = type
	list[id] = self

static func get_item(id: String) -> Item:
	return list.get(id)
