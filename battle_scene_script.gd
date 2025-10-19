extends Node2D

class_name Battle

var balls: Variant
var screen_size: Vector2
var arena_origin: Vector2
var arena_size: Vector2
var spawn_points: Array[Vector2] #= [Vector2(arena_origin.x + arena_size.x / 4, arena_origin.y + arena_size.y / 2), Vector2(arena_origin.x + arena_size.x * 3 / 4, arena_origin.y + arena_size.y / 2), Vector2(arena_origin.x + arena_size.x / 4, arena_origin.y + arena_size.y * 3 / 4), Vector2(arena_origin.x + arena_size.x * 3 / 4, arena_origin.y + arena_size.y * 3 / 4)]
var stat_points: Array[Vector2]
var fighting: Array
var summons: Array
var showing: bool
var prev_teams: Dictionary
var teams: Dictionary
var winner: bool
@export var selection_screen: PackedScene
@export_range (0, 1.0) var button_opacity: float
var clash_sounds: Array = [preload("res://sounds/Hit_ClashA.wav"), preload("res://sounds/Hit_ClashB.wav"), preload("res://sounds/Hit_ClashC.wav")]
@onready var clash_itr = 0
@export var clash_pause: bool = true
@export var cut_ins: bool = true

func _ready() -> void:
	winner = false
	for child: Marker2D in $SpawnPoints.get_children():
		spawn_points.append(child.position)
	for child: Marker2D in $StatPoints.get_children():
		stat_points.append(child.position * scale)
	$Button.modulate.a = button_opacity
	showing = true
	balls = JSON.parse_string(FileAccess.get_file_as_string("res://balls.json"))
	screen_size = get_viewport_rect().size
	arena_origin = $Arena.position
	arena_size = $Arena.size
	
#the final ball number population limit should be <= 32
func begin(fighters: Array):
	var i := 0
	for fighter: Ball in fighters:
		spawn(fighter, spawn_points[i], stat_points[i], i + 1, false)
		i+=1
		teams[fighter.team] = 0
		if clash_pause: fighter.connect("clash", play_clash_sound)
		fighter.connect("summon", summon)
	if teams.size() == 2:
		if prev_teams.size() == 2 && teams.keys()[0] == prev_teams.keys()[0] && teams.keys()[1] == prev_teams.keys()[1] || prev_teams.size() == 2 && teams.keys()[0] == prev_teams.keys()[1] && teams.keys()[1] == prev_teams.keys()[0]:
			teams = prev_teams
		$Scoreboard.show()
	else: $Scoreboard.hide()
	for x in range(50):
		await get_tree().process_frame
	for fighter: Ball in fighters:
		fighter.activate_spawn_ability()
		
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
		
func spawn(ball: Ball, pos: Vector2, stat_pos: Vector2, layer: int, summon: bool):
	ball.position = pos
	ball.set_collision_layer(layer)
	add_child(ball)
	ball.set_avgdmg_position(stat_pos, scale)
	if !summon: fighting.append(ball)
	else: summons.append(ball)
	
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
	for i in range(summons.size() - 1, -1, -1):
		var ball = summons[i]
		summons.remove_at(i)
		if ball != null: ball.queue_free()
	var select_screen: Selection_Screen = selection_screen.instantiate()
	add_sibling(select_screen)
	select_screen.scale = scale
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
	selections = await select_screen.get_selections($SpawnPoints.get_children().size())
	select_screen.hide()
	select_screen.queue_free()
	begin(selections)
	$Button.disabled = false
	$Button.z_index = 1
	showing = true
	clash_itr = 0
	self.show()
	
func play_clash_sound() -> void:
	$ClashAudio.stream = clash_sounds[clash_itr]
	$ClashAudio.play()
	clash_itr = (clash_itr + 1) % 3
	get_tree().paused = true
	await get_tree().create_timer(0.1).timeout
	get_tree().paused = false
	
func summon(cut_in_image: Texture2D, cut_in_voice_line: AudioStream, summoner: Ball, summoned: PackedScene, team: String, amount: int, layer: int) -> void:
	if cut_ins:
		var cut_in: Cut_In = preload("res://cut_in.tscn").instantiate()
		cut_in.set_params("", cut_in_image, cut_in_voice_line)
		add_child(cut_in)
		get_tree().paused = true
		await cut_in.done
		get_tree().paused = false
	
	for i in range(amount):
		var ball: Ball = summoned.instantiate()
		spawn(ball, spawn_points[randi() % 4], Vector2(0, 0), i + 1, true)
		ball.team = team
		ball.layer = layer
		ball.get_avg_dmg().hide()
		summoner.connect("death", ball.die)
	
func get_spawns() -> int:
	return $SpawnPoints.get_children().size()
	
func adopt_bg(txtrect: TextureRect) -> void:
	txtrect.size = $ArenaBorder.size
	txtrect.global_position = $ArenaBorder.global_position
	txtrect.scale = $ArenaBorder.scale
	add_child(txtrect)
	
func adopt_particles(particles: GPUParticles2D) -> void:
	particles.global_position = $Arena.global_position + $Arena.size / 2
	add_child(particles)
