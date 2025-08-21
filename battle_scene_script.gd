extends Node2D

var balls: Variant
var screen_size: Vector2
var arena_origin: Vector2
var arena_size: Vector2
var spawn_points: Array

func _ready() -> void:
	balls = JSON.parse_string(FileAccess.get_file_as_string("res://balls.json"))
	screen_size = get_viewport_rect().size
	arena_origin = $Arena.position
	arena_size = $Arena.size
	spawn_points = [Vector2(arena_origin.x + arena_size.x / 4, arena_origin.y + arena_size.y / 4), Vector2(arena_origin.x + arena_size.x * 3 / 4, arena_origin.y + arena_size.y / 4), Vector2(arena_origin.x + arena_size.x / 4, arena_origin.y + arena_size.y * 3 / 4), Vector2(arena_origin.x + arena_size.x * 3 / 4, arena_origin.y + arena_size.y * 3 / 4)]
	
#the final ball number population limit should be <= 32
func begin(fighters: Array):
	var i := 0
	for fighter in fighters:
		spawn(fighter, spawn_points[i], i + 1)
		i+=1
	get_tree().paused = true
	for n in range(3, 0, -1):
		$Label.text = str(n)
		await get_tree().create_timer(0.5).timeout
	$Label.hide()
	$Label.queue_free()
	get_tree().paused = false
		
func spawn(name: String, pos: Vector2, layer: int):
	var ball_scene = load(balls[name])
	var ball = ball_scene.instantiate()
	ball.position = pos
	ball.set_collision_layer(layer)
	add_child(ball)
	
