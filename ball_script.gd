extends Node2D
class_name Ball

@export var color: Color
@export var border_color: Color
@export var radius: int
@export var lin_accel: int
@export var ang_accel: int
@export var lin_speed: int
@export var ang_speed: int
@export var health: int
@export var attack: int
@export var weapon: bool
var speed_bonus: float
@export var trail: bool
@export var weapon_trail: bool
var hits: int
var total_damage: int
@export var center_force: bool
var center: Vector2


func _ready() -> void:
	center = get_parent().arena_origin + get_parent().arena_size / 2
	hits = 0
	total_damage = 0
	var border_width := radius / 20
	$RigidBody2D/CollisionShape2D.shape.set_radius(radius)
	$RigidBody2D/Face.get_theme_stylebox("panel").expand_margin_left = radius
	$RigidBody2D/Face.get_theme_stylebox("panel").expand_margin_right = radius
	$RigidBody2D/Face.get_theme_stylebox("panel").expand_margin_top = radius
	$RigidBody2D/Face.get_theme_stylebox("panel").expand_margin_bottom = radius
	$RigidBody2D/Face.get_theme_stylebox("panel").bg_color = color
	$RigidBody2D/Face.get_theme_stylebox("panel").border_color = border_color
	$RigidBody2D/Face.get_theme_stylebox("panel").border_width_left = border_width
	$RigidBody2D/Face.get_theme_stylebox("panel").border_width_right = border_width
	$RigidBody2D/Face.get_theme_stylebox("panel").border_width_top = border_width
	$RigidBody2D/Face.get_theme_stylebox("panel").border_width_bottom = border_width
	$RigidBody2D.linear_velocity = Vector2(get_viewport_rect().size.x / 2 - self.position.x  * -1 * lin_speed / 2 * (randf() / 5 + 1), get_viewport_rect().size.y / 2 - self.position.y  * -1 * lin_speed / 2 * (randf() / 5 + 1))
	$RigidBody2D.angular_velocity = ang_speed
	$AvgDmg.global_position.y += 325
	$AvgDmg.global_position.y *= 1.2
	$AvgDmg.add_theme_color_override("font_color", color)
	$AvgDmg.add_theme_color_override("font_outline_color", border_color)
	
	
func _physics_process(delta: float) -> void:
	if $RigidBody2D.linear_velocity.length() < lin_speed * 500: 
		$RigidBody2D.apply_central_force($RigidBody2D.linear_velocity * lin_accel / 4)
	else: 
		$RigidBody2D.apply_central_force($RigidBody2D.linear_velocity * -16 / lin_accel)
		
	if $RigidBody2D.angular_velocity < ang_speed * 4 && ang_speed != 0: 
		$RigidBody2D.apply_torque(ang_accel * 160000)
		
	if center_force:
		$RigidBody2D.apply_central_force(Vector2(center.x - $RigidBody2D.global_position.x, center.y - $RigidBody2D.global_position.y) * 2)
	
	$RigidBody2D/Label.text = str(health)
	speed_bonus = abs(get_velocity_mag()) / 500 + abs($RigidBody2D.angular_velocity) / 8
	if trail: leave_trail()
	if weapon_trail: leave_weapon_trail()

func _on_rigid_body_2d_body_entered(body: Node) -> void:
	pass
		
func set_collision_layer(layer: int):
	for i in range(1, 33):
		$RigidBody2D.set_collision_mask_value(i, true)
	$RigidBody2D.set_collision_mask_value(layer, false)
	$RigidBody2D.set_collision_layer_value(layer, true)

func get_velocity_mag() -> int:
	return $RigidBody2D.linear_velocity.length()
	
func damage_effect(num: int):
	var effect = RichTextLabel.new()
	effect.set_position($RigidBody2D.position + Vector2(int($RigidBody2D.linear_velocity.x) % 10 * -1, int($RigidBody2D.linear_velocity.y) % 10 * -1))
	effect.push_font_size(25)
	effect.push_color(color)
	effect.set_size(Vector2(100, 100))
	effect.push_bold()
	effect.append_text(str(num))
	effect.z_index = 99
	add_child(effect)
	while effect.modulate.a != 0:
		effect.modulate.a -= 0.01
		await get_tree().process_frame
	effect.queue_free()

func leave_trail():
	var effect = $RigidBody2D/Face.duplicate()
	effect.z_index = -1
	effect.position = $RigidBody2D.position
	add_child(effect)
	while effect.modulate.a > 0:
		effect.modulate.a -= 0.1
		await get_tree().process_frame
	effect.queue_free()
	
func leave_weapon_trail():
	var effect = $RigidBody2D.duplicate()
	effect.freeze = true
	effect.z_index = -1
	effect.position = $RigidBody2D.position
	var i = 1
	for nod in effect.get_children():
		if nod.get_children().size() != 1: 
			print(i)
			nod.queue_free()
			i += 1
	add_child(effect)
	while effect.modulate.a > 0:
		effect.modulate.a -= 0.1
		await get_tree().process_frame
	effect.queue_free()


func _on_rigid_body_2d_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	var opp = body.get_parent()
	var enemyCollider = body.shape_owner_get_owner(body.shape_find_owner(body_shape_index))
	var selfCollider = $RigidBody2D.shape_owner_get_owner($RigidBody2D.shape_find_owner(local_shape_index))
	if enemyCollider is Weapon && selfCollider is not Weapon || opp is Ball && !opp.weapon  && selfCollider is not Weapon and opp.get_parent() != self: 
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
			get_parent().fighting.erase(self)
			self.queue_free()

func get_body():
	return $RigidBody2D

func recalc_avg_dmg():
		$AvgDmg.text = "Average\nDamage: " + str(total_damage / hits)
