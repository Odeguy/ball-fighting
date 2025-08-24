extends Camera2D

@export var debug_mode: bool
func _process(delta: float) -> void:
	if debug_mode: position += (get_local_mouse_position() - get_viewport_rect().size / 2) / 200
