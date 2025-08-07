extends Node2D


var selection
func get_selections(num: int) -> Array:
	var selections: Array
	for i in range(0, num):
		selection = null
		while selection == null:
			await get_tree().process_frame
		selections.append(selection)
	return selections
		

func _on_ball_grid_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == 1:
		selection = $ball_grid.get_item_text(index)
