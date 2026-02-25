extends Node2D

class_name Cut_In

var image: Texture2D
var voice_line: AudioStream
var text: String
var show_image: bool
var play_line: bool
var pause_sound: bool

signal done

""""
Init. Set label text, image texture, voice line, and sound effect
1. Quickly color.modulate.a overlay to ~100
2. Play sound_effect
4. Quickly move the border, label, and texture rect to the center in sync
4. Play voice_line
5. hide & queue_free() self
"""

func set_params(name: String, img: Texture2D, voice: AudioStream, show_img: bool, play_snd: bool, pause_snd: bool) -> void:
	text = name
	image = img
	voice_line = voice
	show_image = show_img
	play_line = play_snd
	pause_sound = pause_snd

func _ready() -> void:
	if !show_image:
		$CanvasLayer/Overlay.hide()
		$CanvasLayer/Border.hide()
		$CanvasLayer/Poster.hide()
		$CanvasLayer/Label.hide()
	$CanvasLayer/Overlay.global_position = Vector2(0, 0)
	$CanvasLayer/Poster.texture = image
	$CanvasLayer/Label.text = text
	var tween: Tween = get_tree().create_tween()
	tween.set_speed_scale(16)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	if show_image: await tween.tween_property($CanvasLayer/Overlay, "modulate:a", 0.7, 2)
	if pause_sound: $AudioStreamPlayer2D.play()
	
	var label_diff = $CanvasLayer/Label.position.x - $CanvasLayer/Poster.position.x
	tween.set_parallel()
	$CanvasLayer/Border.global_position.x = 0
	$CanvasLayer/Poster.global_position.x = 0
	$CanvasLayer/Border.modulate.a = 0
	$CanvasLayer/Poster.modulate.a = 0
	
	tween.tween_property($CanvasLayer/Border, "modulate:a", 1, 14)
	tween.tween_property($CanvasLayer/Poster, "modulate:a", 1, 14)
	if pause_sound: await $AudioStreamPlayer2D.finished
	#tween.tween_property($CanvasLayer/Border, "global_position:x", 0, 1)
	#tween.tween_property($CanvasLayer/Poster, "global_position:x", 0, 1)
	if show_image: tween.tween_property($CanvasLayer/Label, "global_position:x", label_diff * -1, 2)
	
	$AudioStreamPlayer2D.stream = voice_line
	if play_line: $AudioStreamPlayer2D.play()
	tween.set_parallel(false)
	tween.tween_property($CanvasLayer/Label, "global_position:x", label_diff * 40, 100)
	if play_line: if voice_line != null: await $AudioStreamPlayer2D.finished
	done.emit()
	self.hide()
	self.queue_free()
