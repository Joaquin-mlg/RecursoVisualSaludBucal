extends Node2D

# --- CONFIGURACIÓN JUEGO ---
@export var duration := 35.0
@export var distancia_alerta := 350.0 # A qué distancia avisa (en pixeles)
@export var cooldown_audio := 1.5     # Segundos entre avisos (para no marear)

# --- REFERENCIAS ---
@onready var progress_bar = $ProgressBar
@onready var timer = $Timer
@onready var audio_player = $AudioStreamPlayer # <--- ¡Necesitas este nodo!

# Arrastra tu Nave aquí en el Inspector
@export var player_ref: Node2D 

# --- AUDIOS ACCESIBILIDAD ---
@export_group("Narrador")
@export var audio_intro: AudioStream         # "Instrucciones del nivel..."
@export var audio_alerta_frente: AudioStream # "¡Cuidado enfrente!"
@export var audio_alerta_izq: AudioStream    # "¡Izquierda!"
@export var audio_alerta_der: AudioStream    # "¡Derecha!"

# --- VARIABLES INTERNAS ---
var elapsed := 0.0
var juego_terminado := false
var tiempo_ultimo_aviso := 0.0 # Para controlar que no hable muy rápido

func _ready():
	# Configurar UI
	progress_bar.max_value = duration
	progress_bar.value = 0
	
	# Configurar Timer Victoria
	timer.wait_time = duration
	timer.one_shot = true
	timer.start()
	
	# 1. NARRACIÓN INICIAL
	_reproducir_prioridad(audio_intro)
	
	# Autodetectar jugador si se te olvidó asignarlo
	if player_ref == null:
		player_ref = get_tree().get_first_node_in_group("player")

func _process(delta):
	if juego_terminado: return
	
	# Actualizar UI
	elapsed += delta
	progress_bar.value = elapsed
	
	# --- LÓGICA DEL RADAR ---
	# Bajamos el contador del cooldown
	if tiempo_ultimo_aviso > 0:
		tiempo_ultimo_aviso -= delta
	else:
		# Si el contador llegó a 0, buscamos peligros
		_radar_de_proximidad()

# --- FUNCIÓN RADAR ---
func _radar_de_proximidad():
	if player_ref == null: return
	
	# Obtenemos todos los asteroides (gracias al cambio en el Spawner)
	var asteroides = get_tree().get_nodes_in_group("Enemigos")
	
	for asteroide in asteroides:
		# Calculamos distancia
		var dist = player_ref.global_position.distance_to(asteroide.global_position)
		
		# Si está cerca Y está por encima de nosotros (para no avisar de los que ya pasamos)
		# (Asumiendo que los asteroides caen desde Y negativo hacia Y positivo)
		if dist < distancia_alerta and asteroide.global_position.y < player_ref.global_position.y:
			
			_analizar_direccion(asteroide)
			return # Solo avisamos del primero que encontremos para no saturar

func _analizar_direccion(asteroide):
	# Calculamos dónde está el asteroide respecto a nosotros
	var diferencia_x = asteroide.global_position.x - player_ref.global_position.x
	
	# Margen de error para considerar que está "En frente" (ej. 50 pixeles)
	if abs(diferencia_x) < 50:
		print("Radar: ¡EN FRENTE!")
		_activar_alerta(audio_alerta_frente)
		
	elif diferencia_x > 0:
		# Positivo significa que el asteroide tiene mayor X (está a la derecha)
		print("Radar: PELIGRO DERECHA")
		_activar_alerta(audio_alerta_der)
		
	else:
		# Negativo significa que está a la izquierda
		print("Radar: PELIGRO IZQUIERDA")
		_activar_alerta(audio_alerta_izq)

func _activar_alerta(audio: AudioStream):
	# 1. Voz
	_reproducir_prioridad(audio)
	
	# 2. Vibración
	if OS.has_feature("mobile"):
		# Vibración larga e intensa (400ms)
		Input.vibrate_handheld(400)
	
	# 3. Reiniciar Cooldown (Callarse por 1.5 segundos)
	tiempo_ultimo_aviso = cooldown_audio

func _reproducir_prioridad(stream: AudioStream):
	if stream == null: return
	
	# Si ya está sonando algo, lo cortamos para dar la alerta urgente
	if audio_player.playing:
		audio_player.stop()
		
	audio_player.stream = stream
	audio_player.play()

# --- FIN DEL JUEGO (GAME OVER / VICTORIA) ---

# Llamado por el asteroide cuando choca
func terminar_juego():
	if juego_terminado: return
	juego_terminado = true
	timer.stop()
	
	print("💥 Game Over")
	GlobalSettings.registrar_partida("Asteroides", int(elapsed*10), int(elapsed), 1)
	
	await get_tree().create_timer(0.5).timeout
	get_tree().reload_current_scene()

# Llamado por el Timer cuando se acaba el tiempo (Ganas)
func _on_timer_timeout() -> void:
	if juego_terminado: return
	juego_terminado = true
	
	print("🏆 Victoria")
	GlobalSettings.registrar_partida("Asteroides", int(duration*10)+500, int(duration), 0)
	
	Transicion.cambiar_escena("res://game/historia/Historia2.tscn")
