extends Floater

func _on_sensory_field_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	var opp = body.get_parent()
	var enemyCollider = body.shape_owner_get_owner(body.shape_find_owner(body_shape_index))
	var selfCollider = $RigidBody2D.shape_owner_get_owner($RigidBody2D.shape_find_owner(local_shape_index))
	match field_type:
		"time_field":
			if opp != self:
				body.linear_damp = time_factor
				body.angular_damp = time_factor
		"attack_field":
			if (
				opp is Ball && 
				opp != self && 
				cooldown == 0
			):
				$RigidBody2D.apply_force((body.global_position - $RigidBody2D.global_position) * 5000 * attack_factor)
				$RigidBody2D.linear_damp = ProjectSettings.get_setting("physics/2d/default_linear_damp")
				$RigidBody2D.angular_damp = ProjectSettings.get_setting("physics/2d/default_angular_damp")
		"dodge_field":
			if (
				opp is Ball && 
				cooldown == 0 || 
				enemyCollider is Weapon
			):
				$"RigidBody2D/Sensory Field/AudioStreamPlayer2D".play()
				var pos = $RigidBody2D.global_position + 2 * (body.global_position - $RigidBody2D.global_position)
				if (
					pos.x > arena_origin.x && 
					pos.y > arena_origin.y && 
					pos.x < arena_origin.x + arena_size.x &&
					pos.y < arena_origin.y + arena_size.y
				): 
					$RigidBody2D.global_position = pos
				$RigidBody2D.apply_force((body.global_position - $RigidBody2D.global_position) * 4000)
				$RigidBody2D.linear_damp = ProjectSettings.get_setting("physics/2d/default_linear_damp")
				$RigidBody2D.angular_damp = ProjectSettings.get_setting("physics/2d/default_angular_damp")
				cooldown = cooldown_length
	if cooldown > 0: cooldown -= 1
