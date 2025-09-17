extends Node2D

class_name Selection_Screen

var balls
func _ready() -> void:
	balls = JSON.parse_string(FileAccess.get_file_as_string("res://balls.json"))
	for name in balls["first_series"]:
		$ball_grid.add_item(name)
	for name in balls["burst_series"]:
		$burst_ball_grid.add_item(name)
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
			var ball_scene = load(selection)
			var ball: Ball = ball_scene.instantiate()
			selections.push_back(ball)
			previous = ball
			ball.team += str(randi())
	return selections

@onready var shadow_max = $Label2.get_theme_constant("shadow_offset_x")
@onready var dshadow = -1
@onready var count = 0
func _process(delta: float) -> void:
	count += 1
	if count % 15 != 0: return
	var new_offset = $Label2.get_theme_constant("shadow_offset_x") + dshadow
	$Label2.add_theme_constant_override("shadow_offset_x", new_offset)
	$Label2.add_theme_constant_override("shadow_offset_y", new_offset)
	$Label3.add_theme_constant_override("shadow_offset_x", new_offset)
	$Label3.add_theme_constant_override("shadow_offset_y", new_offset)
	if $Label2.get_theme_constant("shadow_offset_x") == 2 || $Label2.get_theme_constant("shadow_offset_x") == shadow_max: dshadow *= -1
		

func _on_ball_grid_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	$AudioStreamPlayer2D.play()
	if mouse_button_index == 1:
		selection = balls["first_series"][$ball_grid.get_item_text(index)]

func _on_burst_ball_grid_item_clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	$AudioStreamPlayer2D.play()
	if mouse_button_index == 1:
		selection = balls["burst_series"][$burst_ball_grid.get_item_text(index)]


func _on_button_pressed() -> void:
	$AudioStreamPlayer2D.stream = preload("res://sounds/SE151_System_OK_2.wav")
	$AudioStreamPlayer2D.play()
	await $AudioStreamPlayer2D.finished
	selection = $Button.text


func _on_team_1_pressed() -> void:
	$AudioStreamPlayer2D.play()
	if previous != null:
		previous.team = $"Team 1".text


func _on_team_2_pressed() -> void:
	$AudioStreamPlayer2D.play()
	if previous != null:
		previous.team = $"Team 2".text


func _on_team_3_pressed() -> void:
	$AudioStreamPlayer2D.play()
	if previous != null:
		previous.team = $"Team 3".text


func _on_team_4_pressed() -> void:
	$AudioStreamPlayer2D.play()
	if previous != null:
		previous.team = $"Team 4".text
