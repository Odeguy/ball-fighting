extends Node2D
class_name Ball

@export var color: Color
@export var border_color: Color
@export var radius: int
@export var accel: int
@export var speed: int
@export var health: int
@export var attack: int
var speed_bonus: float


func _ready() -> void:
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
	
	
func _physics_process(delta: float) -> void:
	if $RigidBody2D.linear_velocity.length() < speed * 500: 
		$RigidBody2D.apply_central_force($RigidBody2D.linear_velocity * accel / 7)
		
	else: 
		$RigidBody2D.apply_central_force($RigidBody2D.linear_velocity * -1)
	$RigidBody2D/Label.text = str(health)
	speed_bonus = get_velocity_mag() / 500

func _on_rigid_body_2d_body_entered(body: Node) -> void:
	var opp = body.get_parent()
	if opp is Ball: 
		health -= opp.attack + opp.speed_bonus
		if health <= 0:
			self.hide()
			self.queue_free()
		
func set_collision_layer(layer: int):
	for i in range(1, 33):
		$RigidBody2D.set_collision_mask_value(i, true)
	$RigidBody2D.set_collision_mask_value(layer, false)
	$RigidBody2D.set_collision_layer_value(layer, true)

func get_velocity_mag() -> int:
	return $RigidBody2D.linear_velocity.length()
