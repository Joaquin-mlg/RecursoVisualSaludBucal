extends Node2D

@onready var sprite = $Sprite2D
var imagenes = [
	preload("res://game/assets/fondos/historia3_1.png"),
	preload("res://game/assets/fondos/historia3_2.png"),
	preload("res://game/assets/fondos/historia3_3.png"),
]
var indice = 0

func _ready():
	sprite.texture = imagenes[indice]
	position = get_viewport_rect().size / 2
	#$AudioStreamPlayer.play() # si quieres reproducir narración

func _unhandled_input(event):
	if (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed):
		indice += 1
		if indice < imagenes.size():
			sprite.texture = imagenes[indice]
		else:
			get_tree().change_scene_to_file("res://game/minijuegos/clasificacion/Clasificacion.tscn")

func _on_next_pressed():
	indice += 1
	if indice < imagenes.size():
		sprite.texture = imagenes[indice]
	else:
		get_tree().change_scene_to_file("res://game/minijuegos/clasificacion/Clasificacion.tscn")
