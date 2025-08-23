extends Ball

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


func _ready() -> void:
	center = get_parent().center
	var border_width := radius / 20
	$RigidBody2D.angular_velocity = ang_speed
	set_collision_layer(0)
	
	
func _physics_process(delta: float) -> void:
	$RigidBody2D.apply_central_force((get_parent().get_body().position - $RigidBody2D.position) * 20)
	
func _on_rigid_body_2d_body_entered(body: Node) -> void:
	pass
		
func set_collision_layer(layer: int):
	for i in range(1, 33):
		$RigidBody2D.set_collision_mask_value(i, true)
		$RigidBody2D.set_collision_layer_value(i, true)
	
func damage_effect(num: int):
	pass

func leave_trail():
	pass


func _on_rigid_body_2d_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	pass
