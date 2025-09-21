extends Node2D
class_name Ball

@export var color: Color
@export var border_color: Color
@export var health_color: Color
@export var radius: int
@export var border_width: int
@export var lin_accel: int
@export var ang_accel: int
@export var lin_speed: int
@export var ang_speed: int
@export var health: int
@export var regeneration: int
@export var attack: int
@export var weapon: bool
var speed_bonus: float
@export var trail: bool
@export var weapon_trail: bool
var hits: int
var total_damage: int
@export var center_force: bool
@export_enum("time_field", "attack_field", "dodge_field") var field_type: String
@export var time_factor: int
@export var black_flash: bool
@export var flash_chance: float
var center: Vector2
var arena_origin: Vector2
var arena_size: Vector2
@export var attack_sound: AudioStream
@export var team: String
var hit_limit: float
var cooldown = 0
signal clash
@onready var black_flash_scene: PackedScene = preload("res://black_flash.tscn")
@export_category("Summon")
@export var summon_enabled: bool
@export var summon_limit: float = -1
@export var summon_cut_in_image: Texture2D
@export var summon_cut_in_voice_line: AudioStream
@export var summoned: PackedScene
signal summon(summon_cut_in_image, summon_cut_in_voice_line, summoner, summoned, team)
@onready var max_health: float = float(health)
@onready var counter: int = 0
signal death


func _ready() -> void:
	if border_width == 0: border_width = radius / 15
	$AudioStreamPlayer2D.stream = attack_sound
	hit_limit = 0.2
	arena_origin = get_parent().arena_origin
	arena_size = get_parent().arena_size
	center = arena_origin + arena_size / 2
	hits = 0
	total_damage = 0
	$RigidBody2D/CollisionShape2D.shape.set_radius(radius)
	$RigidBody2D/Face.get_theme_stylebox("panel").expand_margin_left = radius
	$RigidBody2D/Face.get_theme_stylebox("panel").expand_margin_right = radius
	$RigidBody2D/Face.get_theme_stylebox("panel").expand_margin_top = radius
	$RigidBody2D/Face.get_theme_stylebox("panel").expand_margin_bottom = radius
	$RigidBody2D/Face.get_theme_stylebox("panel").bg_color = color
	$RigidBody2D/Face.get_theme_stylebox("panel").border_color = border_color
	$RigidBody2D/Label.add_theme_color_override("font_color", health_color)
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
	
func _process(delta: float) -> void:
	counter += 1
	try_summon()
	regenerate(counter)
	
func _physics_process(delta: float) -> void:
	if $RigidBody2D.linear_velocity.length() < lin_speed * 500: 
		$RigidBody2D.apply_central_force($RigidBody2D.linear_velocity * lin_accel / 2 + Vector2(1, 1))
	else: 
		$RigidBody2D.apply_central_force($RigidBody2D.linear_velocity * -16 / lin_accel)
		
	if $RigidBody2D.angular_velocity < ang_speed * 4 && ang_speed != 0: 
		$RigidBody2D.apply_torque(ang_accel * 160000)
		
	if center_force:
		$RigidBody2D.apply_central_force(Vector2(center.x - $RigidBody2D.global_position.x, center.y - $RigidBody2D.global_position.y) * 2)
	if hit_limit < 0.2: hit_limit += 0.01
	
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
	
func damage_effect(num: int) -> void:
	var effect = RichTextLabel.new()
	$AudioStreamPlayer2D.stop()
	$AudioStreamPlayer2D.play()
	effect.set_position($RigidBody2D.position + Vector2(int($RigidBody2D.linear_velocity.x) % 10 * -1, int($RigidBody2D.linear_velocity.y) % 10 * -1) * (randi() % 50 - 25))
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

func record_hit(damage: int) -> void:
		hits += 1
		total_damage += damage

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
	var enemyCollider: CollisionShape2D = body.shape_owner_get_owner(body.shape_find_owner(body_shape_index))
	var selfCollider: CollisionShape2D = $RigidBody2D.shape_owner_get_owner($RigidBody2D.shape_find_owner(local_shape_index))
	if local_shape_index == 1 && enemyCollider is Weapon:
			clash.emit()
			get_tree().paused = true
			await get_tree().create_timer(0.1).timeout
			get_tree().paused = false
	#after this point the shape indexes and collider variables get messed up for some reason that i'm not looking into right now
	if enemyCollider is Weapon && selfCollider is not Weapon && opp.team != self.team && hit_limit >= 0.2 || opp is Ball && !opp.weapon  && selfCollider is not Weapon and opp.get_parent() != self && opp.team != self.team && hit_limit >= 0.2: 
		var damage: int = opp.attack + opp.speed_bonus
		if opp.black_flash && randf() <= opp.flash_chance:
			damage *= 2
			await opp.black_flash_attack()
		health -= damage
		hit_limit = 0
		opp.damage_effect(damage)
		opp.record_hit(damage)
		opp.recalc_avg_dmg()
		if health <= 0:
			die()
			
func die() -> void:
	$RigidBody2D.linear_velocity = Vector2(0, 0)
	$RigidBody2D.angular_velocity = 0
	$RigidBody2D/CollisionShape2D.disabled = true
	if weapon: $RigidBody2D/WeaponShape2D.disabled = true
	health = 0
	while modulate.a <= 0:
		modulate.a -= 0.05
		await get_tree().process_frame
	get_parent().fighting.erase(self)
	death.emit()
	self.queue_free()

func get_body():
	return $RigidBody2D

func get_avg_dmg():
	return $AvgDmg

func recalc_avg_dmg():
		if hits > 0: $AvgDmg.text = "Average\nDamage: " + str(total_damage / hits)

func get_audio() -> AudioStreamPlayer2D:
	return $AudioStreamPlayer2D

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
			if opp is Ball && opp != self && cooldown == 0:
				$RigidBody2D.apply_force((body.global_position - $RigidBody2D.global_position) * 4000)
				$RigidBody2D.linear_damp = ProjectSettings.get_setting("physics/2d/default_linear_damp")
				$RigidBody2D.angular_damp = ProjectSettings.get_setting("physics/2d/default_angular_damp")
		"dodge_field":
			if opp is Ball && cooldown == 0 || enemyCollider is Weapon:
				$"RigidBody2D/Sensory Field/AudioStreamPlayer2D".play()
				var pos = $RigidBody2D.global_position + 2 * (body.global_position - $RigidBody2D.global_position)
				if pos.x > arena_origin.x && pos.y > arena_origin.y && pos.x < arena_origin.x + arena_size.x && pos.y < arena_origin.y + arena_size.y: $RigidBody2D.global_position = pos
				$RigidBody2D.apply_force((body.global_position - $RigidBody2D.global_position) * 4000)
				$RigidBody2D.linear_damp = ProjectSettings.get_setting("physics/2d/default_linear_damp")
				$RigidBody2D.angular_damp = ProjectSettings.get_setting("physics/2d/default_angular_damp")
				cooldown = 2
	if cooldown > 0: cooldown -= 1
					
		


func _on_sensory_field_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body != null && field_type == "time_field":
		var opp = body.get_parent()
		body.linear_damp = 0
		body.angular_damp = 0
		if opp.lin_accel > 0: body.linear_velocity = Vector2(randi() % (opp.lin_accel * 2) - opp.lin_accel, randi() % (opp.lin_accel * 2) - opp.lin_accel) * 50
		
func black_flash_attack() -> int:
	var scene: Black_Flash = black_flash_scene.instantiate()
	$RigidBody2D/Weapon.add_child(scene)
	return 2
	
func death_bound(sig: String) -> void:
	connect(sig, die)
	
func try_summon() -> void:
	if health / max_health  <= summon_limit && summon_enabled:
		summon_enabled = false
		summon.emit(summon_cut_in_image, summon_cut_in_voice_line, self, summoned, team)

func regenerate(counter: int) -> void:
	if counter % 50 == 0 && health < max_health: health += regeneration
