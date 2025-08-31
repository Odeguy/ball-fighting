extends Node2D

var balls: Variant
var screen_size: Vector2
var arena_origin: Vector2
var arena_size: Vector2
var spawn_points: Array
var fighting: Array
var showing: bool
var prev_teams: Dictionary
var teams: Dictionary
var winner: bool
@export var selection_screen: PackedScene
@export_range (0, 1.0) var button_opacity: float

func _ready() -> void:
	winner = false
	$Button.modulate.a = button_opacity
	showing = true
	balls = JSON.parse_string(FileAccess.get_file_as_string("res://balls.json"))
	screen_size = get_viewport_rect().size
	arena_origin = $Arena.position
	arena_size = $Arena.size
	spawn_points = [Vector2(arena_origin.x + arena_size.x / 4, arena_origin.y + arena_size.y / 2), Vector2(arena_origin.x + arena_size.x * 3 / 4, arena_origin.y + arena_size.y / 2), Vector2(arena_origin.x + arena_size.x / 4, arena_origin.y + arena_size.y * 3 / 4), Vector2(arena_origin.x + arena_size.x * 3 / 4, arena_origin.y + arena_size.y * 3 / 4)]
	
#the final ball number population limit should be <= 32
func begin(fighters: Array):
	var i := 0
	for fighter in fighters:
		spawn(fighter, spawn_points[i], i + 1)
		i+=1
		teams[fighter.team] = 0
	if teams.size() == 2:
		if prev_teams.size() == 2 && teams.keys()[0] == prev_teams.keys()[0] && teams.keys()[1] == prev_teams.keys()[1] || prev_teams.size() == 2 && teams.keys()[0] == prev_teams.keys()[1] && teams.keys()[1] == prev_teams.keys()[0]:
			teams = prev_teams
		$Scoreboard.show()
	else: $Scoreboard.hide()
		
func _process(delta: float) -> void:
	if showing && get_global_mouse_position().x > arena_origin.x && get_global_mouse_position().y > arena_origin.y && get_global_mouse_position().x < arena_origin.x + arena_size.x && get_global_mouse_position().y < arena_origin.y + arena_size.y:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if fighting.size() == 1 && !winner:
		winner = true
		teams[fighting[0].team] += 1
		$AudioStreamPlayer2D.play()
	if teams.size() == 2: $Scoreboard.text = str(teams[teams.keys()[0]]) + " - " + str(teams[teams.keys()[1]])
		
func spawn(ball: Object, pos: Vector2, layer: int):
	ball.position = pos
	ball.set_collision_layer(layer)
	add_child(ball)
	fighting.append(ball)
	
func countdown() -> void:
	$Label.show()
	get_tree().paused = true
	for n in range(3, 0, -1):
		$Label.text = str(n)
		await get_tree().create_timer(0.5).timeout
	$Label.hide()
	get_tree().paused = false


func _on_button_pressed() -> void:
	for i in range(fighting.size() - 1, -1, -1):
		var ball = fighting[i]
		fighting.remove_at(i)
		ball.queue_free()
	var select_screen = selection_screen.instantiate()
	add_sibling(select_screen)
	var tween = create_tween()
	tween.set_parallel()
	tween.set_speed_scale(6)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property($start_button, "modulate:a", 0, 1)
	tween.tween_property($Panel, "modulate:a", 0, 2)
	var selections: Array
	$Button.z_index = -10
	$Button.disabled = true
	showing = false
	winner = false
	prev_teams = teams
	$Scoreboard.hide()
	self.hide()
	teams = {}
	selections = await select_screen.get_selections()
	select_screen.hide()
	select_screen.queue_free()
	begin(selections)
	$Button.disabled = false
	$Button.z_index = 1
	showing = true
	self.show()
	
func set_mouse_mode(mode: int) -> void:
	$Aren
