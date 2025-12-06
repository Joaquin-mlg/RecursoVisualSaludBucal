extends Node2D

const PROGRESO_MAXIMO = 100.0
var juego_completado = false 

@onready var progreso_limpieza = $UI/ProgresoLimpieza

# --- VARIABLES PARA EL REPORTE ---
var tiempo_inicio: int = 0
var errores: int = 0 # Puedes sumar errores si usan la herramienta incorrecta (opcional)

func _ready():
	progreso_limpieza.max_value = PROGRESO_MAXIMO
	progreso_limpieza.value = 0
	
	# Guardamos la hora de inicio para calcular cuánto tardó el niño
	tiempo_inicio = Time.get_ticks_msec()
	
	# Asegúrate de agregar este nodo al grupo para que las Rocas lo encuentren fácil
	add_to_group("nivel_cepillar")

func actualizar_progreso(valor_a_sumar: float):
	progreso_limpieza.value += valor_a_sumar
	progreso_limpieza.value = clamp(progreso_limpieza.value, 0, PROGRESO_MAXIMO)
	
	# Condición de Victoria
	if progreso_limpieza.value >= PROGRESO_MAXIMO and not juego_completado:
		juego_completado = true
		terminar_juego()

func terminar_juego():
	print("¡Nivel Completado! Generando reporte...")
	
	# 1. Calcular tiempo
	var tiempo_fin = Time.get_ticks_msec()
	var segundos_totales = (tiempo_fin - tiempo_inicio) / 1000
	
	# 2. Calcular Puntaje (Ejemplo: 1000 puntos base - tiempo que tardó)
	# Si tarda mucho, el puntaje baja, pero nunca menos de 100
	var puntaje = max(100, 1000 - (segundos_totales * 5))
	
	# 3. GUARDAR EN LA LIBRETA GLOBAL
	GlobalSettings.registrar_partida(
		"Limpieza de Asteroide", # Nombre del juego
		int(puntaje),
		int(segundos_totales),
		errores
	)
	
	# 4. Feedback final (Sonido/Vibración)
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(500) # Vibración larga de victoria
	
	# 5. Esperar un poco y cambiar de escena
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://game/historia/Historia3.tscn")
