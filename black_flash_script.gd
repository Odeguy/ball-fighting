extends Node2D

class_name Black_Flash


func _ready() -> void:
	$AudioStreamPlayer2D.play()
	await $AudioStreamPlayer2D.finished
	self.hide()
	self.queue_free()
