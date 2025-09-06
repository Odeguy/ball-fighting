extends Node2D

class_name Burst

@export var sound_effect: AudioStream
@export var duration: float
signal enemy_detected
signal done

""""
1. Wait for Ball detection
2. Show beam
3. Delay
4. Send signal
5. hide & queue_free
"""

func _ready() -> void:
	self.hide()
	
func _on_area_detector_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	var opp = body.get_parent()
	var enemyCollider = body.shape_owner_get_owner(body.shape_find_owner(body_shape_index))
	var selfCollider = $RigidBody2D.shape_owner_get_owner($RigidBody2D.shape_find_owner(local_shape_index))
	if opp is not Ball: return
	enemy_detected.emit()
	
	self.show()
	var counter = 0
	var ball: Ball = self.get_parent()
	while duration > 0:
		get_tree().process_frame
		duration -= 1.0 / 60.0
		if opp.health >= 0 & counter % 120 == 0: opp.health -= 1
		ball.damage_effect(1)
		ball.total_damage += 1
		opp.recalc_avg_dmg()
		counter += 1
	done.emit()
	self.hide()
	self.queue_free()
