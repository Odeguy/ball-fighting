extends Node2D

var balls: Variant
var screen_size: Vector2
var arena_origin: Vector2
var arena_size: Vector2
var spawn_points: Array
var fighting: Array
@export var selection_screen: PackedScene

func _ready() -> void:
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
		
func spawn(name: String, pos: Vector2, layer: int):
	var ball_scene = load(balls[name])
	var ball = ball_scene.instantiate()
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
	for ball in fighting:
		fighting.erase(ball)
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
	selections = await select_screen.get_selections()
	select_screen.hide()
	select_screen.queue_free()
	begin(selections)
