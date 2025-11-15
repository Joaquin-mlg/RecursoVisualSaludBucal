extends Node2D

@onready var sprite = $Sprite2D
var imagenes = [
	preload("res://game/assets/fondos/historia1_1.png"),
	preload("res://game/assets/fondos/historia1_2.png"),
	preload("res://game/assets/fondos/historia1_3.png"),
	preload("res://game/assets/fondos/historia1_4.png")
]
var indice = 0

func _ready():
	sprite.texture = imagenes[indice]
	#$AudioStreamPlayer.play() # si quieres reproducir narración

func _unhandled_input(event):
	if (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed):
		indice += 1
		if indice < imagenes.size():
			sprite.texture = imagenes[indice]
		else:
			get_tree().change_scene_to_file("res://game/minijuegos/esquivar/Esquivar.tscn")

func _on_next_pressed():
	indice += 1
	if indice < imagenes.size():
		sprite.texture = imagenes[indice]
	else:
		get_tree().change_scene_to_file("res://game/minijuegos/esquivar/Esquivar.tscn")
