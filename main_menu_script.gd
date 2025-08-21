extends Node2D
@export var selection_screen: PackedScene
@export var battle_scene: PackedScene

func _on_start_button_pressed() -> void:
	var selections = await go_to_select()
	await battle(selections)

func go_to_select() -> Array:
	var select_screen = selection_screen.instantiate()
	add_sibling(select_screen)
	self.hide()
	var selections: Array
	selections = await select_screen.get_selections()
	select_screen.hide()
	remove_child(select_screen)
	return selections
	
func battle(selections: Array):
	var battle = battle_scene.instantiate()
	add_sibling(battle)
	battle.begin(selections)
	
