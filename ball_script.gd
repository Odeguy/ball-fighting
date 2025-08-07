extends Node2D
class_name Ball

@export var color: Color
@export var radius: int
@export var speed: int
@export var health: int
@export var attack: int
@export var weapon_image: Texture


func _ready() -> void:
	var border_width := radius / 20
	$RigidBody2D/CollisionShape2D.shape.set_radius(radius)
	$RigidBody2D/Face.get_theme_stylebox("panel").expand_margin_left = radius
	$RigidBody2D/Face.get_theme_stylebox("panel").expand_margin_right = radius
	$RigidBody2D/Face.get_theme_stylebox("panel").expand_margin_top = radius
	$RigidBody2D/Face.get_theme_stylebox("panel").expand_margin_bottom = radius
	$RigidBody2D/Face.get_theme_stylebox("panel").bg_color = color
	$RigidBody2D/Face.get_theme_stylebox("panel").border_width_left = border_width
	$RigidBody2D/Face.get_theme_stylebox("panel").border_width_right = border_width
	$RigidBody2D/Face.get_theme_stylebox("panel").border_width_top = border_width
	$RigidBody2D/Face.get_theme_stylebox("panel").border_width_bottom = border_width
	$RigidBody2D.apply_impulse(Vector2(speed * randi() % 2 + 1, speed * randi() % 2 + 1))
	$RigidBody2D.add_constant_torque(speed)
	#weapon init
	
	
func _physics_process(delta: float) -> void:
	var x_force = get_viewport_rect().size.x / 2 - self.position.x
	var y_force = get_viewport_rect().size.y / 2 - self.position.y
	$RigidBody2D.apply_central_force(Vector2(x_force, y_force) * speed)
	$RigidBody2D/Label.text = str(health)

func _on_rigid_body_2d_body_entered(body: Node) -> void:
	var opp = body.get_parent()
	if opp is Ball: 
		health -= opp.attack
		
func set_collision_layer(layer: int):
	for i in range(1, 33):
		$RigidBody2D.set_collision_mask_value(i, true)
	$RigidBody2D.set_collision_mask_value(layer, false)
	$RigidBody2D.set_collision_layer_value(layer, true)
