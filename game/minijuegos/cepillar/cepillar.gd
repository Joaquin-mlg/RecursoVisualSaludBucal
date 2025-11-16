extends Node2D

const PROGRESO_MAXIMO = 100.0

@onready var progreso_limpieza = $UI/ProgresoLimpieza

func _ready():
	progreso_limpieza.max_value = PROGRESO_MAXIMO
	progreso_limpieza.value = 0

func actualizar_progreso(valor_a_sumar: float):
	progreso_limpieza.value += valor_a_sumar
	progreso_limpieza.value = clamp(progreso_limpieza.value, 0, PROGRESO_MAXIMO)
