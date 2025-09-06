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
	$Poster.texture = image
	$Label.text = text
	for i in range(100):
		$Overlay.color.a += 1
		get_tree().process_frame
	$AudioStreamPlayer2D.play()
	
	var label_diff = $Label.position.x - $Poster.position.x
	var tween: Tween = get_tree().create_tween()
	tween.set_parallel()
	tween.tween_property($Border, "position:x", 0, 2)
	tween.tween_property($Poster, "position:x", label_diff, 2)
	await tween.tween_property($Label, "position:x", 0, 2)
	
	$AudioStreamPlayer2D.stream = voice_line
	$AudioStreamPlayer2D.play()
	await $AudioStreamPlayer2D.finished
	done.emit()
	self.hide()
	self.queue_free()
