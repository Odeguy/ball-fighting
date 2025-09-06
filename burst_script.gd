extends Node2D

class_name Burst

@export var sound_effect: AudioStream
@export var duration: float
signal enemy_detected
signal done
var opp

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
	
func _on_area_detector_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.get_parent() is Ball && body.get_parent() != self.get_parent().get_parent().get_parent(): 
		opp = body.get_parent()
		enemy_detected.emit()
	
func blast() -> void:
	self.show()
	var counter = 0
	var ball: Ball = self.get_parent().get_parent().get_parent()
	while duration > 0:
		await get_tree().process_frame
		if opp == null: break
		duration -= 1.0 / 60.0
		if opp.health >= 0 && counter % 120 == 0: opp.health -= 1
		opp.damage_effect(1)
		ball.total_damage += 1
		opp.recalc_avg_dmg()
		counter += 1
	done.emit()
	self.hide()
	self.queue_free()
