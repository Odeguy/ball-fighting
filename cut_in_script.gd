extends Node2D

class_name Cut_In

var image: Texture2D
var voice_line: AudioStream
var text: String

signal done

""""
Init. Set label text, image texture, voice line, and sound effect
1. Quickly color.modulate.a overlay to ~100
2. Play sound_effect
4. Quickly move the border, label, and texture rect to the center in sync
4. Play voice_line
5. hide & queue_free() self
"""

func set_params(name: String, img: Texture2D, voice: AudioStream) -> void:
	text = name
	image = img
	voice_line = voice

func _ready() -> void:
	$Overlay.global_position = Vector2(0, 0)
	$Poster.texture = image
	$Label.text = text
	var tween: Tween = get_tree().create_tween()
	tween.set_speed_scale(16)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	await tween.tween_property($Overlay, "modulate:a", 0.7, 2)
	$AudioStreamPlayer2D.play()
	
	var label_diff = $Label.position.x - $Poster.position.x
	tween.set_parallel()
	$Border.global_position.x = 0
	$Poster.global_position.x = 0
	$Border.modulate.a = 0
	$Poster.modulate.a = 0
	
	tween.tween_property($Border, "modulate:a", 1, 14)
	tween.tween_property($Poster, "modulate:a", 1, 14)
	await $AudioStreamPlayer2D.finished
	#tween.tween_property($Border, "global_position:x", 0, 1)
	#tween.tween_property($Poster, "global_position:x", 0, 1)
	await tween.tween_property($Label, "global_position:x", label_diff * -1, 2)
	
	$AudioStreamPlayer2D.stream = voice_line
	$AudioStreamPlayer2D.play()
	tween.set_parallel(false)
	tween.tween_property($Label, "global_position:x", label_diff * 40, 100)
	await $AudioStreamPlayer2D.finished
	done.emit()
	self.hide()
	self.queue_free()
