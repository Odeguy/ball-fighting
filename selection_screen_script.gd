extends Node2D

class_name Selection_Screen

var balls
func _ready() -> void:
	balls = JSON.parse_string(FileAccess.get_file_as_string("res://balls.json"))
	for name in balls:
		$ball_grid.add_item(name)
	
var selection
var previous
func get_selections() -> Array:
	var selections: Array
	for i in range(0, 5):
		$Label.text = str(i)
		selection = null
		while selection == null:
			await get_tree().process_frame
		if i < 4:
			if selection == "Done": break
			var ball_scene = load(balls[selection])
			var ball: Ball = ball_scene.instantiate()
			selections.push_back(ball)
			previous = ball
			ball.team += str(randi())
	return selections
		

func _on_ball_grid_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == 1:
		selection = $ball_grid.get_item_text(index)


func _on_button_pressed() -> void:
	selection = $Button.text


func _on_team_1_pressed() -> void:
	if previous != null:
		previous.team = $"Team 1".text


func _on_team_2_pressed() -> void:
	if previous != null:
		previous.team = $"Team 2".text


func _on_team_3_pressed() -> void:
	if previous != null:
		previous.team = $"Team 3".text


func _on_team_4_pressed() -> void:
	if previous != null:
		previous.team = $"Team 4".text
