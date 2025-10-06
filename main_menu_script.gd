extends Node2D

class_name Main_Menu

@export var selection_screen: PackedScene
var battle_scene: PackedScene
var battle_stage: Battle
var camera_scale: Vector2

func _on_start_button_pressed(battle: String) -> void:
	battle_scene = load(battle)
	battle_stage = battle_scene.instantiate()
	battle_stage.hide()
	add_child(battle_stage)
	var spawns = battle_stage.get_spawns()
	camera_scale = Vector2(1, 1) / battle_stage.scale
	$Camera2D.zoom = camera_scale
	remove_child(battle_stage)
	battle_stage.show()
	$AudioStreamPlayer2D.play()
	var selections = await go_to_select(spawns)
	await battle(selections)

func go_to_select(spawns: int) -> Array:
	var select_screen = selection_screen.instantiate()
	add_sibling(select_screen)
	select_screen.scale = Vector2(1, 1) / camera_scale
	var tween = create_tween()
	tween.set_parallel()
	tween.set_speed_scale(6)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($standard_select, "modulate:a", 0, 1)
	tween.tween_property($space_select, "modulate:a", 0, 1)
	tween.tween_property($arena_select, "modulate:a", 0, 1)
	tween.tween_property($circle_select, "modulate:a", 0, 1)
	tween.tween_property($huge_select, "modulate:a", 0, 1)
	tween.tween_property($Panel, "modulate:a", 0, 2)
	$standard_select.mouse_filter = 2
	$space_select.mouse_filter = 2
	$arena_select.mouse_filter = 2
	$circle_select.mouse_filter = 2
	$huge_select.mouse_filter = 2
	$Panel.mouse_filter = 2
	var selections: Array
	selections = await select_screen.get_selections(spawns)
	select_screen.hide()
	select_screen.queue_free()
	return selections
	
func battle(selections: Array):
	add_sibling(battle_stage)
	battle_stage.begin(selections)
	


func _on_standard_select_pressed() -> void:
	_on_start_button_pressed("res://battle_stages/standard_battle_scene.tscn")


func _on_space_select_pressed() -> void:
	_on_start_button_pressed("res://battle_stages/space_battle_scene.tscn")


func _on_arena_select_pressed() -> void:
	_on_start_button_pressed("res://battle_stages/arena_battle_scene.tscn")


func _on_circle_select_pressed() -> void:
	_on_start_button_pressed("res://battle_stages/circle_battle_scene.tscn")


func _on_huge_select_pressed() -> void:
	_on_start_button_pressed("res://battle_stages/huge_battle_scene.tscn")
