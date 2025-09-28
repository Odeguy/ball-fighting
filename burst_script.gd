extends Node2D

class_name Burst

@export var sound_effect: AudioStream
@export var duration: float
@export var burst_damage: int
signal enemy_detected
signal done
var opp: Ball
var user: Ball
var initial_stats: Dictionary
@export var laser: bool = true
@export var burst_modifiers: Dictionary = {
	"attack": 1.0,
	"regeneration": 1.0,
	"lin_speed": 1.0,
	"lin_accel": 1.0,
	"ang_speed": 1.0,
	"ang_accel": 1.0,
	"burst_limit": 1.0,
	"cooldown_length": 2.0
}

""""
1. Wait for Ball detection
2. Show beam
3. Delay
4. Send signal
5. hide & queue_free
"""

func _ready() -> void:
	self.hide()
	$AreaDetector.show()
	$AreaDetector/CollisionShape2D.show()
	$AudioStreamPlayer2D.stream = sound_effect
	
func _on_area_detector_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.get_parent() is Ball && body.get_parent() != user && body.get_parent() is not Floater && body.get_parent() is not Bomb && body.get_parent().team != user.team: 
		opp = body.get_parent()
		enemy_detected.emit()
	
func blast() -> void:
	self.show()
	var counter = 0
	var ball: Burst_Ball = self.get_parent().get_parent().get_parent()
	set_burst_modifiers(ball)
	while duration > 0:
		await get_tree().process_frame
		ball.burst = 0
		if get_tree().paused: continue
		if counter % 10 == 0: $AudioStreamPlayer2D.play()
		duration -= 1.0 / 60.0
		counter += burst_damage
		if opp == null: break
		if !$AreaDetector.overlaps_body(opp.get_body()): continue
		if opp.health >= 0 && counter % 16 == 0: opp.health -= burst_damage
		if opp.health < 0: opp.health = 0
		if burst_damage != 0: opp.damage_effect(burst_damage)
		ball.total_damage += 1
		opp.recalc_avg_dmg()
		if opp.health == 0:
			opp.die()
			break
	reset_stats(ball)
	done.emit()
	self.hide()
	self.queue_free()

func set_burst_modifiers(ball: Burst_Ball) -> void:
	initial_stats["attack"] = ball.attack
	initial_stats["lin_speed"] = ball.lin_speed
	initial_stats["lin_accel"] = ball.lin_accel
	initial_stats["ang_speed"] = ball.ang_speed
	initial_stats["ang_accel"] = ball.ang_accel
	initial_stats["regeneration"] = ball.regeneration
	initial_stats["cooldown_length"] = ball.cooldown_length
	
	if(burst_modifiers["attack"] != 1): ball.attack = burst_modifiers["attack"]
	if(burst_modifiers["lin_speed"] != 1): ball.lin_speed = burst_modifiers["lin_speed"]
	if(burst_modifiers["lin_accel"] != 1): ball.lin_accel = burst_modifiers["lin_accel"]
	if(burst_modifiers["ang_speed"] != 1): ball.ang_speed = burst_modifiers["ang_speed"]
	if(burst_modifiers["ang_accel"] != 1): ball.ang_accel = burst_modifiers["ang_accel"]
	if(burst_modifiers["regeneration"] != 1): ball.regeneration = burst_modifiers["regeneration"]
	if(burst_modifiers["cooldown_length"] != 1): ball.cooldown_length = burst_modifiers["cooldown_length"]
	if(burst_modifiers["burst_limit"] != 1): ball.burst_limit *= burst_modifiers["burst_limit"]
	ball.round_stats()
	ball.scaling(0)

func reset_stats(ball: Burst_Ball) -> void:
	ball.attack = initial_stats["attack"]
	ball.lin_speed = initial_stats["lin_speed"]
	ball.lin_accel = initial_stats["lin_accel"]
	ball.ang_speed = initial_stats["ang_speed"]
	ball.ang_accel = initial_stats["ang_accel"]
	ball.cooldown_length = initial_stats["cooldown_length"]
	
