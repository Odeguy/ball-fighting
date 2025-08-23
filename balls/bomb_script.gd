extends "res://balls/floater_script.gd"

@export var explosion_texture: Texture2D
@export var spawn_rate: int
var spawn_timer: int

func _ready() -> void:
	spawn_rate *= 1000
	set_collision_layer(0)
	$RigidBody2D.linear_velocity = Vector2(get_viewport_rect().size.x / 2 - self.global_position.x  * -1 * lin_speed / 2 * (randf() / 5 + 1), get_viewport_rect().size.y / 2 - self.global_position.y  * -1 * lin_speed / 2 * (randf() / 5 + 1))
	spawn_timer = 0
	
func _physics_process(delta: float) -> void:
	$RigidBody2D.apply_central_force((get_parent().get_body().position - $RigidBody2D.position) * 0.01)
	$RigidBody2D.apply_central_force(Vector2(1000, 0))
	speed_bonus = abs(get_velocity_mag()) / 1000 + abs($RigidBody2D.angular_velocity) / 24
	if center_force:
		$RigidBody2D.apply_central_force(Vector2(center.x - $RigidBody2D.global_position.x, center.y - $RigidBody2D.global_position.y) * 2)
	if trail: leave_trail()
	spawn_timer += 1
	if spawn_timer % spawn_rate == 0: create_bomb()
	
	
func _on_rigid_body_2d_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	var opp = body.get_parent()
	var enemyCollider = body.shape_owner_get_owner(body.shape_find_owner(body_shape_index))
	var selfCollider = $RigidBody2D.shape_owner_get_owner($RigidBody2D.shape_find_owner(local_shape_index))
	if vulnerable:
		if enemyCollider is Weapon || opp is Ball && !opp.weapon  && selfCollider is not Weapon && opp.get_parent() != self && opp.get_parent() != self.get_parent(): 
			health -= opp.attack + opp.speed_bonus
			damage_effect(opp.attack + opp.speed_bonus)
			opp.hits += 1
			opp.total_damage += opp.attack + opp.speed_bonus
			opp.recalc_avg_dmg()
			if health <= 0:
				$RigidBody2D.linear_velocity = Vector2(0, 0)
				$RigidBody2D.angular_velocity = 0
				$RigidBody2D/CollisionShape2D.disabled = true
				if weapon: $RigidBody2D/WeaponShape2D.disabled = true
				health = 0
				while modulate.a <= 0:
					modulate.a -= 0.05
					await get_tree().process_frame
				self.queue_free()
	elif opp is Ball && opp != self.get_parent() || opp is Weapon && opp != self.get_parent():
		$RigidBody2D.linear_velocity = Vector2(0, 0)
		$RigidBody2D.angular_velocity = 0
		$RigidBody2D/CollisionShape2D.disabled = true
		$RigidBody2D/Weapon/TextureRect.texture = explosion_texture
		while modulate.a <= 0:
			modulate.a -= 0.05
			await get_tree().process_frame
		self.queue_free()

func create_bomb() -> void:
	var dupe = self.duplicate()
	dupe.position = center
	dupe.visible = true
	dupe.get_collider().disabled = false
	add_sibling(dupe)
	
func get_collider():
	return $RigidBody2D/CollisionShape2D
