extends Node2D

func _ready() -> void:
	var balls = JSON.parse_string(FileAccess.get_file_as_string("res://balls.json"))
	for name in balls:
		$ball_grid.add_item(name)
	
var selection
func get_selections() -> Array:
	var selections: Array
	for i in range(0, 4):
		selection = null
		while selection == null:
			await get_tree().process_frame
		if selection == "Done": break
		selections.push_back(selection)
	return selections
		

func _on_ball_grid_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == 1:
		selection = $ball_grid.get_item_text(index)


func _on_button_pressed() -> void:
	selection = $Button.text
