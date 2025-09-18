extends Node2D

class_name Burst

@export var sound_effect: AudioStream
@export var duration: float
@export var burst_damage: int
signal enemy_detected
signal done
var opp: Ball

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
	if body.get_parent() is Ball && body.get_parent() != self.get_parent().get_parent().get_parent(): 
		opp = body.get_parent()
		enemy_detected.emit()
	
func blast() -> void:
	self.show()
	var counter = 0
	var ball: Burst_Ball = self.get_parent().get_parent().get_parent()
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
		opp.damage_effect(burst_damage)
		ball.total_damage += 1
		opp.recalc_avg_dmg()
		if opp.health == 0:
			opp.die()
			break
	done.emit()
	self.hide()
	self.queue_free()
