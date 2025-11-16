# Script: Cepillar.gd

extends Node2D

const PROGRESO_MAXIMO = 100.0
# Bandera para evitar que la escena se cargue múltiples veces
var juego_completado = false 

@onready var progreso_limpieza = $UI/ProgresoLimpieza

func _ready():
	progreso_limpieza.max_value = PROGRESO_MAXIMO
	progreso_limpieza.value = 0

func actualizar_progreso(valor_a_sumar: float):
	# Sumar el valor y asegurar que no pase de 100
	progreso_limpieza.value += valor_a_sumar
	progreso_limpieza.value = clamp(progreso_limpieza.value, 0, PROGRESO_MAXIMO)
	
	# 1. Verificar la condición de victoria
	if progreso_limpieza.value >= PROGRESO_MAXIMO and not juego_completado:
		juego_completado = true
		cargar_siguiente_escena()

func cargar_siguiente_escena():
	# 2. Cargar la nueva escena
	var siguiente_escena_ruta = "res://game/historia/Historia3.tscn"
	
	# IMPORTANTE: Reemplaza la ruta de arriba con la ubicación real de tu archivo.
	
	print("¡Minijuego Completado! Cargando: " + siguiente_escena_ruta)
	
	# Usa get_tree().change_scene_to_file() para cambiar a la nueva escena
	get_tree().change_scene_to_file(siguiente_escena_ruta)
