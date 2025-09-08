extends Ball

class_name Burst_Ball

var burst: int
@onready var cut_in_scene: PackedScene = preload("res://cut_in.tscn")

@export_category("Cut In")
@export var burst_name: String
@export var cut_in_image: Texture2D
@export var cut_in_voice_line: AudioStream

@export_category("Burst")
@export var burst_scene: PackedScene
@export var burst_limit: int

func _ready() -> void:
	super()
	reset_burst_meter()
	$RigidBody2D/BurstGlow.process_material.set_emission_sphere_radius(float(radius))
	
func damage_effect(num: int) -> void:
	super(num)
	increase_burst_meter(num)

func increase_burst_meter(num: int) -> void:
	if burst == burst_limit: return
	burst += num
	if burst > burst_limit: burst = burst_limit
	$AvgDmg/BurstMeter.scale.x = float(burst) / burst_limit
	if burst == burst_limit: burst_ready()

func reset_burst_meter() -> void:
	burst = 0
	$AvgDmg/BurstMeter.scale.x = 0
	$RigidBody2D/BurstGlow.hide()

func burst_ready() -> void:
	var player = AudioStreamPlayer2D.new()
	player.stream = load("res://sounds/Cmn_EnergyRelease.wav")
	player.play()
	$RigidBody2D/BurstGlow.show()
	burst_attack()
	await player.finished
	player.queue_free()

func cut_in() -> void:
	var scene: Cut_In = cut_in_scene.instantiate()
	scene.set_params(burst_name, cut_in_image, cut_in_voice_line)
	add_child(scene)
	get_tree().paused = true
	await scene.done
	get_tree().paused = false
	
func burst_attack() -> void:
	var scene: Burst = burst_scene.instantiate()
	$RigidBody2D/Weapon.add_child(scene)
	await scene.enemy_detected
	await cut_in()
	$RigidBody2D.lock_rotation = true
	var ls = lin_speed
	var la = lin_accel
	lin_speed = 1
	lin_accel = 1
	scene.blast()
	await scene.done
	$RigidBody2D.lock_rotation = false
	lin_speed = ls
	lin_accel = la
	reset_burst_meter()
