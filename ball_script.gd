extends Node2D
class_name Ball

@export var color: Color
@export var border_color: Color
@export var radius: int
@export var accel: int
@export var speed: int
@export var health: int
@export var attack: int
@export var weapon: bool
var speed_bonus: float
@export var trail: bool
var hits: int
var total_damage: int


func _ready() -> void:
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
	$RigidBody2D.linear_velocity = Vector2(get_viewport_rect().size.x / 2 - self.position.x  * -1 * speed / 2, get_viewport_rect().size.y / 2 - self.position.y  * -1 * speed / 2)
	$AvgDmg.global_position.y += 750
	$AvgDmg.add_theme_color_override("font_color", color)
	$AvgDmg.add_theme_color_override("font_outline_color", border_color)
	
	
func _physics_process(delta: float) -> void:
	if $RigidBody2D.linear_velocity.length() < speed * 500: 
		$RigidBody2D.apply_central_force($RigidBody2D.linear_velocity * accel / 4)
	else: 
		$RigidBody2D.apply_central_force($RigidBody2D.linear_velocity * -16 / accel)
	$RigidBody2D/Label.text = str(health)
	speed_bonus = get_velocity_mag() / 500
	if trail: leave_trail()

func _on_rigid_body_2d_body_entered(body: Node) -> void:
	hits += 1
	total_damage += self.attack + self.speed_bonus
	$AvgDmg.text = "Average\nDamage: " + str(total_damage / hits)
	var opp = body.get_parent()
	if body is Weapon || opp is Ball && !opp.weapon: 
		health -= opp.attack + opp.speed_bonus
		damage_effect(opp.attack + opp.speed_bonus)
		if health <= 0:
			$RigidBody2D.linear_velocity = Vector2(0, 0)
			$RigidBody2D/CollisionShape2D.disabled = true
			if weapon: $RigidBody2D/WeaponShape2D.disabled = true
			health = 0
			while modulate.a <= 0:
				modulate.a -= 0.05
				await get_tree().process_frame
			self.queue_free()
		
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
	while effect.modulate.a != 0:
		effect.modulate.a -= 0.1
		await get_tree().process_frame
	effect.queue_free()
