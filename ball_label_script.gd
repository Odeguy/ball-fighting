extends Label

@onready var ball: Ball = get_parent()
@onready var body: RigidBody2D = ball.get_body()
	
func _physics_process(delta: float) -> void:
	self.global_position = Vector2(body.global_position.x - self.size.x / 2, body.global_position.y - self.size.y / 2)
