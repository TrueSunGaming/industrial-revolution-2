extends Node

var player: Player
var ui: UI
var hud: HUD
var quest_hud: QuestHUD
var main: Main
var factory: Factory
var world_container: WorldContainer
var hover_indicator: HoverIndicator
var blank_texture := global.create_blank_texture(Vector2i(32, 32), Color("#242424"))

const preloaded = [
	# TileEntityData
	preload("res://scenes/factory/tile_sys/tiles/portal.tres"),
	preload("res://scenes/factory/tile_sys/tiles/assembler_1.tres"),
	
	# MachineData
	preload("res://scenes/factory/tile_sys/tiles/assembler_1-machine.tres"),
	
	# Item
	preload("res://global/inventory_sys/items/assembler_1.tres"),
	
	# Recipe
	preload("res://global/inventory_sys/recipes/test.tres")
]
