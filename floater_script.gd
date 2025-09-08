extends Ball

class_name Floater
#@export var color: Color
#@export var border_color: Color
#@export var radius: int
#@export var lin_accel: int
#@export var ang_accel: int
#@export var lin_speed: int
#@export var ang_speed: int
#@export var health: int
#@export var attack: int
#@export var weapon: bool
#var speed_bonus: float
#@export var trail: bool
#var hits: int
#var total_damage: int
#@export var center_force: bool
#var center: Vector2
@export var vulnerable: bool


func _ready() -> void:
	team = get_parent().team
	center = get_parent().center
	$RigidBody2D.angular_velocity = ang_speed
	set_collision_layer(0)
	
	
func _physics_process(delta: float) -> void:
	$RigidBody2D.apply_central_force((get_parent().get_body().position - $RigidBody2D.position) * 20)
	speed_bonus = abs(get_velocity_mag()) / 1000 + abs($RigidBody2D.angular_velocity) / 24
	if center_force:
		$RigidBody2D.apply_central_force(Vector2(center.x - $RigidBody2D.global_position.x, center.y - $RigidBody2D.global_position.y) * 2)
	if trail: leave_trail()
	
func _on_rigid_body_2d_body_entered(body: Node) -> void:
	pass
		
func set_collision_layer(layer: int):
	for i in range(1, 33):
		$RigidBody2D.set_collision_mask_value(i, true)
		$RigidBody2D.set_collision_layer_value(i, true)
	

func leave_trail():
	pass
	

func damage_effect(num: int):
	var effect = RichTextLabel.new()
	get_parent().get_audio().stop()
	get_parent().get_audio().play()
	effect.set_position($RigidBody2D.position + Vector2(int($RigidBody2D.linear_velocity.x) % 10 * -1, int($RigidBody2D.linear_velocity.y) % 10 * -1))
	effect.push_font_size(25)
	effect.push_color(get_parent().color)
	effect.set_size(Vector2(100, 100))
	effect.push_bold()
	effect.append_text(str(num))
	effect.z_index = 99
	add_child(effect)
	while effect.modulate.a != 0:
		effect.modulate.a -= 0.01
		await get_tree().process_frame
	effect.queue_free()

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
	
func recalc_avg_dmg():
	get_parent().hits = hits
	get_parent().total_damage = total_damage
	get_parent().recalc_avg_dmg()
