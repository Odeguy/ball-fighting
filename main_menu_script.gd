extends Node2D

class_name Main_Menu

@export var selection_screen: PackedScene
@export var battle_scene: PackedScene

func _on_start_button_pressed() -> void:
	var selections = await go_to_select()
	await battle(selections)

func go_to_select() -> Array:
	var select_screen = selection_screen.instantiate()
	add_sibling(select_screen)
	var tween = create_tween()
	tween.set_parallel()
	tween.set_speed_scale(6)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($start_button, "modulate:a", 0, 1)
	tween.tween_property($Panel, "modulate:a", 0, 2)
	$start_button.mouse_filter = 2
	$Panel.mouse_filter = 2
	var selections: Array
	selections = await select_screen.get_selections()
	select_screen.hide()
	select_screen.queue_free()
	return selections
	
func battle(selections: Array):
	var battle = battle_scene.instantiate()
	add_sibling(battle)
	battle.begin(selections)
	
