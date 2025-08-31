extends Area2D

class_name SensoryField

var radius: float
@export var field_multiply: float

func _ready() -> void:
	radius = get_parent().get_parent().radius * field_multiply
	$CollisionShape2D.shape.set_radius(radius)
	$Face.get_theme_stylebox("panel").expand_margin_left = radius
	$Face.get_theme_stylebox("panel").expand_margin_right = radius
	$Face.get_theme_stylebox("panel").expand_margin_top = radius
	$Face.get_theme_stylebox("panel").expand_margin_bottom = radius
