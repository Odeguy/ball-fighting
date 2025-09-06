extends Node2D

class_name Game

@export var main_menu_scene: PackedScene
@export var selection_screen: PackedScene
@export var battle_scene: PackedScene

func _ready() -> void:
	var start_menu: Main_Menu = main_menu_scene.instantiate()
	add_child(start_menu)
