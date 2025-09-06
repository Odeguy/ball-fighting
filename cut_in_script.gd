extends Node2D

@export var image: Texture2D
@export var sound_effect: AudioStream
@export var voice_line: AudioStream

""""
Init. Set label text, image texture, voice line, and sound effect
1. Quickly modulate overlay to ~.3
2. Play sound_effect
4. Quickly move the border, label, and texture rect to the center in sync
4. Play voice_line
5. hide & queue_free() self
"""
