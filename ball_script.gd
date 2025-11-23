extends Node2D
class_name Ball

@export var color: Color
@export var border_color: Color
@export var health_color: Color
@export var radius: int
@export var border_width: int
@export var lin_accel: float
@export var ang_accel: float
@export var lin_speed: float
@export var ang_speed: float
@export var health: int
@export var regeneration: float
@export var attack: float
@export var weapon: bool
var speed_bonus: float
@export var trail: bool
@export var trail_freq: int = 1
@export var weapon_trail: bool
var hits: int
var total_damage: int
@export var center_force: bool
@export_enum("time_field", "attack_field", "dodge_field") var field_type: String
@export var cooldown_length: int = 2
@export var time_factor: int
@export var black_flash: bool
@export var flash_chance: float
@export_enum("7 Incarnations", "Trace: On", "Steal!!", "Help from Reinhard") var spawn_ability: String
@export var return_by_death: bool
signal returning(ball)
var center: Vector2
var arena_origin: Vector2
var arena_size: Vector2
@export var attack_sound: AudioStream
var team: String
var hit_limit: float
var cooldown = 0
signal clash
@onready var cut_in_scene: PackedScene = preload("res://cut_in.tscn")
@onready var black_flash_scene: PackedScene = preload("res://black_flash.tscn")
@export_category("Summon")
@export var summon_enabled: bool
@export var summon_limit: float = -1
@export var summon_cut_in_image: Texture2D
@export var summon_cut_in_voice_line: AudioStream
@export var summoned: PackedScene
@export var summon_death_linked: bool = true
@export var summon_burst_enabled: bool = true
@export_category("Stat Scaling")
@export var scaling_vars: Dictionary = {
	"attack": 1.0,
	"regeneration": 1.0,
	"lin_speed": 1.0,
	"lin_accel": 1.0,
	"ang_speed": 1.0,
	"ang_accel": 1.0
}
@export var scale_on_hit: bool
signal summon(summon_cut_in_image, summon_cut_in_voice_line, summoner, summoned, team, amount, layer, death_linked, burst_enabled)
@onready var max_health: float = float(health)
@onready var counter: int = 0
@onready var physics_counter: int = 0
signal death
var camera_scale: Vector2
var layer: int


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
	#$AvgDmg.global_position.y += 325
	#$AvgDmg.global_position.y *= 1.2
	$AvgDmg.add_theme_color_override("font_color", color)
	$AvgDmg.add_theme_color_override("font_outline_color", border_color)
	scaling(0)
	
func _process(delta: float) -> void:
	counter += 1
	try_summon(1, false, summon_death_linked, summon_burst_enabled)
	regenerate(counter)
	scaling(counter)
	
func _physics_process(delta: float) -> void:
	physics_counter += 1
	if $RigidBody2D.linear_velocity.length() < lin_speed * 500: 
		$RigidBody2D.apply_central_force($RigidBody2D.linear_velocity * lin_accel / 2 + Vector2(1, 1))
	else: 
		$RigidBody2D.apply_central_force($RigidBody2D.linear_velocity * -16 / lin_accel)
		
	if $RigidBody2D.angular_velocity < abs(ang_speed) * 4 && ang_speed != 0 && !$RigidBody2D.lock_rotation: 
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
		
func set_collision_layer(layerq: int):
	for i in range(1, 33):
		$RigidBody2D.set_collision_mask_value(i, true)
	$RigidBody2D.set_collision_mask_value(layerq, false)
	$RigidBody2D.set_collision_layer_value(layerq, true)
	layer = layerq

func set_avgdmg_position(pos: Vector2, sc: Vector2):
	$AvgDmg.global_position = pos
	camera_scale = Vector2(1, 1) / sc
	$AvgDmg.scale = camera_scale

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
	if physics_counter % trail_freq != 0: return
	var effect = $RigidBody2D/Face.duplicate()
	effect.scale = camera_scale
	effect.z_index = -1
	effect.position = $RigidBody2D.position
	add_child(effect)
	while effect.modulate.a > 0:
		effect.modulate.a -= 0.1
		await get_tree().process_frame
	effect.queue_free()
	
func leave_weapon_trail():
	var effect = $RigidBody2D.duplicate(8)
	effect.freeze = true
	effect.z_index = -1
	effect.position = $RigidBody2D.position
	var i = 1
	for nod in effect.get_children():
		if nod.get_children().size() != 1: 
			nod.queue_free()
			i += 1
	add_child(effect)
	while effect.modulate.a > 0:
		effect.modulate.a -= 0.1
		await get_tree().process_frame
	effect.queue_free()


func _on_rigid_body_2d_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	var opp = body.get_parent()
	var enemyCollider  = body.shape_owner_get_owner(body.shape_find_owner(body_shape_index))
	var selfCollider = $RigidBody2D.shape_owner_get_owner($RigidBody2D.shape_find_owner(local_shape_index))
	if local_shape_index == 1 && enemyCollider is Weapon:
			clash.emit()
	#after this point the shape indexes and collider variables get messed up for some reason that i'm not looking into right now
	if enemyCollider is Weapon && selfCollider is not Weapon && opp.team != self.team && hit_limit >= 0.2 || opp is Ball && !opp.weapon  && selfCollider is not Weapon and opp.get_parent() != self && opp.team != self.team && hit_limit >= 0.2: 
		var damage: int = int(opp.attack + opp.speed_bonus)
		if opp.black_flash && randf() <= opp.flash_chance:
			damage *= 2
			await opp.black_flash_attack()
		health -= damage
		hit_limit = 0
		opp.damage_effect(damage)
		if scale_on_hit: scaling(0)
		opp.record_hit(damage)
		opp.recalc_avg_dmg()
		if health <= 0:
			die()
			
func die() -> void:
	if return_by_death:
		returning.emit(self)
		return
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
				cooldown = cooldown_length
	if cooldown > 0: cooldown -= 1
					
		


func _on_sensory_field_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body != null && field_type == "time_field":
		var opp = body.get_parent()
		body.linear_damp = 0
		body.angular_damp = 0
		if opp.lin_accel > 0: body.linear_velocity = Vector2(randi() % int(opp.lin_accel * 2) - opp.lin_accel, randi() % int(opp.lin_accel * 2) - opp.lin_accel) * 50
		
func black_flash_attack() -> int:
	var scene: Black_Flash = black_flash_scene.instantiate()
	$RigidBody2D/Weapon.add_child(scene)
	return 2
	
func death_bound(sig: String) -> void:
	connect(sig, die)
	
func try_summon(amount: int, bypass: bool, death_linked: bool, burst_enabled: bool) -> void:
	if health / max_health  <= summon_limit && summon_enabled || bypass:
		summon_enabled = false
		summon.emit(summon_cut_in_image, summon_cut_in_voice_line, self, summoned, team, amount, layer, death_linked, summon_enabled)

func regenerate(counter: int) -> void:
	if counter % 20 == 0 && health < max_health: health += regeneration
	if health > max_health: health = max_health

func scaling(counter: int) -> void:
	if counter % 600 != 0: return
	attack *= scaling_vars["attack"]
	lin_speed *= scaling_vars["lin_speed"]
	lin_accel *= scaling_vars["lin_accel"]
	ang_speed *= scaling_vars["ang_speed"]
	ang_accel *= scaling_vars["ang_accel"]
	regeneration *= scaling_vars["regeneration"]
	round_stats()
	$AvgDmg/Scaling.text = ""
	for i in range(0, scaling_vars.size()):
		var key = scaling_vars.keys()[i]
		if scaling_vars[key] > 1 || key == "regeneration" && regeneration != 0:
			$AvgDmg/Scaling.text += key + ": " + str(get_stat(key)) + "\n"
			
func get_stat(stat: String) -> Variant:
	match stat:
		"attack": return attack
		"lin_speed": return lin_speed
		"lin_accel": return lin_accel
		"ang_speed": return ang_speed
		"ang_accel": return ang_accel
		"regeneration": return regeneration
	return "No Matches"

func round_stats() -> void:
	attack = snappedf(attack, 0.01)
	lin_speed = snappedf(lin_speed, 0.01)
	lin_accel = snappedf(lin_accel, 0.01)
	ang_speed = snappedf(ang_speed, 0.01)
	ang_accel = snappedf(ang_accel, 0.01)
	regeneration = snappedf(regeneration, 0.01)

func activate_spawn_ability() -> void:
	match spawn_ability:
		"7 Incarnations":
			max_health *= 1.3
			summon_enabled = true
			summoned = load(self.scene_file_path)
			try_summon(3, true, summon_death_linked, summon_burst_enabled)
		"Trace: On":
			await cut_in("Trace: On", load("res://burst_series/cut_in_components/images/7dbkruiygm131_jpg.png"), load("res://burst_series/cut_in_components/voice_lines/traceon.wav"))
			trace_weapon()
		"Steal!!":
			await cut_in("Steal!!", load("res://burst_series/cut_in_components/images/steal.png"), load("res://burst_series/cut_in_components/voice_lines/steal-(kazuma)-made-with-Voicemod.mp3"))
			var target = await trace_weapon()
			if target != null: target.lose_weapon()
		"Help from Reinhard":
			if randf() < 0.15: try_summon(1, true, summon_death_linked, summon_burst_enabled)
			
func trace_weapon() -> Ball:
	var battle: Battle = self.get_parent()
	var target: Ball
	for fighter: Ball in battle.fighting:
		if fighter == self: continue
		if fighter.weapon && fighter.get_weapon_properties()[4] != null:
			var properties = fighter.get_weapon_properties()
			var blank = TextureRect.new()
			blank.name = "TextureRect"
			$RigidBody2D/Weapon/TextureRect.replace_by(blank)
			$RigidBody2D/Weapon/TextureRect.position = properties[0]
			$RigidBody2D/Weapon/TextureRect.rotation = properties[1]
			$RigidBody2D/Weapon/TextureRect.size = properties[2]
			$RigidBody2D/Weapon/TextureRect.scale = properties[3]
			$RigidBody2D/Weapon/TextureRect.texture = properties[4]
			$RigidBody2D/WeaponShape2D.position = properties[5]
			$RigidBody2D/WeaponShape2D.rotation = properties[6]
			$RigidBody2D/WeaponShape2D.scale = properties[7]
			$RigidBody2D/WeaponShape2D.shape = properties[8]
			$RigidBody2D/WeaponShape2D/AudioStreamPlayer2D.stream = properties[9]
			attack = fighter.attack
			self.weapon = true
			target = fighter
			break
		else:
			var found: bool
			for node in fighter.get_children():
				if node is Floater or node is Bomb:
					var dupe = node.duplicate()
					attack = fighter.attack * 0.85
					add_child(dupe)
					found = true
					target = fighter
			if found:
				break
	return target
			
func get_weapon_properties() -> Array:
	var texture_rect: TextureRect = $RigidBody2D/Weapon/TextureRect
	var weapon_shape_2d: CollisionShape2D = $RigidBody2D/WeaponShape2D
	var weapon_audio: AudioStream = $AudioStreamPlayer2D.stream
	return [texture_rect.position, texture_rect.rotation, texture_rect.size, texture_rect.scale, texture_rect.texture,
		weapon_shape_2d.position, weapon_shape_2d.rotation, weapon_shape_2d.scale, weapon_shape_2d.shape, 
		weapon_audio]

func lose_weapon() -> void:
	$RigidBody2D/Weapon/TextureRect.hide()
	$RigidBody2D/WeaponShape2D.disabled = true
	attack *= 0.2
	for node in get_children():
		if node is Floater or node is Bomb:
			node.hide()
			node.queue_free()
	weapon = false

func cut_in(text: String, image: Texture2D, voice_line: AudioStream) -> void:
	var scene: Cut_In = cut_in_scene.instantiate()
	scene.set_params(text, image, voice_line)
	add_child(scene)
	get_tree().paused = true
	await scene.done
	get_tree().paused = false

func rbt_miasma() -> void:
	$RBDSound.play()
	$RigidBody2D/RBDMiasma.emitting = true
	
