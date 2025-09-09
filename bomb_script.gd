extends "res://floater_script.gd"

class_name Bomb

@export var explosion_texture: Texture2D
@export var spawn_rate: int
@export var duped: bool
var spawn_timer: int

func _ready() -> void:
	team = get_parent().team
	set_collision_layer(0)
	spawn_timer = 0
	if duped:
		while !($RigidBody2D.global_position.x > get_parent().arena_origin.x && $RigidBody2D.global_position.y > get_parent().arena_origin.y && $RigidBody2D.global_position.x < get_parent().arena_origin.x + get_parent().arena_size.x && $RigidBody2D.global_position.y < get_parent().arena_origin.y + get_parent().arena_size.y):
			$RigidBody2D.global_position = get_parent().global_position + Vector2(randi() % 51, randi() % 51)
	
func _physics_process(delta: float) -> void:
	$RigidBody2D.apply_central_force((get_parent().get_body().position - $RigidBody2D.position) * 0.01)
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
		if enemyCollider is Weapon && opp.team != self.team|| opp is Ball && !opp.weapon  && selfCollider is not Weapon && opp.get_parent() != self && opp.get_parent() != self.get_parent() && opp.team != self.team: 
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
	if opp is Ball && opp != self.get_parent() && self.get_parent() != opp.get_parent() && opp.team != self.team:
		$RigidBody2D.linear_velocity = Vector2(0, 0)
		$RigidBody2D.angular_velocity = 0
		$RigidBody2D.freeze = true
		$RigidBody2D/CollisionShape2D.disabled = true
		$RigidBody2D/TextureRect.visible = false
		$RigidBody2D/TextureRect2.visible = true
		while modulate.a > 0:
			modulate.a -= 0.02
			await get_tree().process_frame
		self.queue_free()

func create_bomb() -> void:
	var dupe = self.duplicate()
	dupe.modulate.a = 1
	center = get_parent().center
	dupe.visible = true
	dupe.get_collider().disabled = false
	dupe.get_body().freeze = false
	dupe.get_body().linear_velocity = Vector2(0, 0)
	dupe.get_body().angular_velocity = 0
	dupe.duped = true
	dupe.spawn_rate *= self.spawn_rate * 3
	await add_sibling(dupe)
	
func get_collider():
	return $RigidBody2D/CollisionShape2D
