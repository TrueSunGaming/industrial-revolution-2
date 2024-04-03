extends Node

var player: Player
var ui: UI
var hud: HUD
var quest_hud: QuestHUD
var main: Main
var factory: Factory
var world_container: WorldContainer
var hover_indicator: HoverIndicator

const preloaded = [
	preload("res://scenes/factory/tile_sys/tiles/Portal.tres")
]
