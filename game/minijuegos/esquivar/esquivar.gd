extends Node2D

@export var duration := 15.0  # tiempo total del minijuego

@onready var progress_bar = $ProgressBar
@onready var timer = $Timer

# Variables para control y reporte
var elapsed := 0.0
var juego_terminado := false # Bandera para evitar que ganes y pierdas al mismo tiempo

func _ready():
	# Configurar barra
	progress_bar.max_value = duration
	progress_bar.value = 0
	
	# Configurar timer
	timer.wait_time = duration
	timer.one_shot = true
	timer.start()

func _process(delta):
	# Si el juego ya terminó (ganó o perdió), no actualizamos nada
	if juego_terminado or timer.is_stopped():
		return
	
	elapsed += delta
	progress_bar.value = elapsed

# --- CASO 1: PERDER (Llamado por asteroide.gd) ---
func terminar_juego():
	if juego_terminado:
		return # Evita doble ejecución
	
	juego_terminado = true
	timer.stop() # Detenemos el reloj
	
	print("💥 Game Over: Guardando reporte...")
	
	# CALCULAMOS LOS DATOS
	# Puntaje: 10 puntos por cada segundo que sobrevivió
	var puntaje_actual = int(elapsed * 10)
	var tiempo_jugado = int(elapsed)
	var errores = 1 # Chocar cuenta como 1 error fatal
	
	# GUARDAMOS EN LA LIBRETA
	GlobalSettings.registrar_partida("Esquivar Asteroides (Intento Fallido)", puntaje_actual, tiempo_jugado, errores)
	
	# Reiniciamos el nivel tras una pausa corta
	await get_tree().create_timer(0.5).timeout
	get_tree().reload_current_scene()

# --- CASO 2: GANAR (Se acabó el tiempo) ---
func _on_timer_timeout() -> void:
	if juego_terminado:
		return
		
	juego_terminado = true
	print("🏆 ¡Victoria! Guardando reporte...")
	
	# CALCULAMOS LOS DATOS DE VICTORIA
	# Puntaje: Puntos por tiempo + un BONO de 500 por ganar
	var puntaje_final = int(duration * 10) + 500
	var tiempo_jugado = int(duration)
	var errores = 0 # Victoria limpia
	
	# GUARDAMOS EN LA LIBRETA
	GlobalSettings.registrar_partida("Esquivar Asteroides (Victoria)", puntaje_final, tiempo_jugado, errores)
	
	# Cambiamos a la siguiente historia
	get_tree().change_scene_to_file("res://game/historia/Historia2.tscn")
