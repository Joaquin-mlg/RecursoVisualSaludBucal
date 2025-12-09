extends Node2D

const PROGRESO_MAXIMO = 100.0
var juego_completado = false

# --- REFERENCIAS VISUALES ---
@onready var progreso_limpieza = $UI/ProgresoLimpieza
@onready var asteroide_visual = $Asteroide # Referencia al nodo padre del asteroide
@onready var asteroide_sprite = $Asteroide/Spriteateroide
@export var textura_asteroide_feliz: Texture2D

# --- REFERENCIAS DE AUDIO ---
@onready var musica_fondo = $AudioStreamPlayer2D
@onready var narrador = $Narrador # <--- ¡NUEVO! (Crea este nodo AudioStreamPlayer)

# --- CONFIGURACIÓN DE ACCESIBILIDAD ---
@export_group("Narración y Guía")
@export var audio_intro: AudioStream          # "¡El asteroide está sucio! Frota la pantalla para limpiarlo."
@export var audio_info_asteroide: AudioStream # "Este es el asteroide. Está lleno de polvo."
@export var audio_victoria: AudioStream       # "¡Muy bien! Quedó reluciente."

var tiempo_inicio: int = 0
var errores: int = 0 

func _ready():
	progreso_limpieza.max_value = PROGRESO_MAXIMO
	progreso_limpieza.value = 0
	tiempo_inicio = Time.get_ticks_msec()
	add_to_group("nivel_cepillar")
	
	# 1. INICIAR MÚSICA
	if musica_fondo:
		musica_fondo.play()
	
	# 2. INICIAR NARRACIÓN (Instrucciones)
	_reproducir_narracion(audio_intro)

	# 3. CONECTAR IDENTIFICACIÓN DE OBJETOS (Accesibilidad)
	# Intentamos conectar la señal del asteroide para que diga "Soy un asteroide" al tocarlo
	if asteroide_visual:
		# Si el nodo tiene la señal mouse_entered (Area2D, TextureButton, etc.)
		if asteroide_visual.has_signal("mouse_entered"):
			asteroide_visual.mouse_entered.connect(_on_asteroide_tocado)
		else:
			# Si es un Sprite simple, advertimos
			push_warning("El nodo Asteroide no detecta input. Agrega un Area2D o hazlo TextureButton.")

	if not asteroide_sprite:
		push_warning("¡Cuidado! No se encontró el nodo del sprite.")

# --- LÓGICA DE LIMPIEZA ---
# Esta función la llama tu herramienta (cepillo) constantemente mientras frotas
func actualizar_progreso(valor_a_sumar: float):
	if juego_completado: return

	progreso_limpieza.value += valor_a_sumar
	progreso_limpieza.value = clamp(progreso_limpieza.value, 0, PROGRESO_MAXIMO)
	
	# --- VIBRACIÓN (FEEDBACK HÁPTICO) ---
	# Vibramos suavemente mientras se limpia para que se sienta el "cepillado"
	if OS.has_feature("mobile"):
		# 50ms es una vibración muy corta, ideal para sentir textura
		Input.vibrate_handheld(50)

	if progreso_limpieza.value >= PROGRESO_MAXIMO:
		juego_completado = true
		terminar_juego()

# --- FUNCIONES DE NARRACIÓN ---
func _reproducir_narracion(stream: AudioStream):
	if stream == null: return
	
	# Si el narrador ya está hablando, lo detenemos para decir lo nuevo
	if narrador.playing:
		narrador.stop()
	
	narrador.stream = stream
	narrador.play()

func _on_asteroide_tocado():
	# Esta función se activa al pasar el dedo/mouse por el asteroide
	if not juego_completado:
		_reproducir_narracion(audio_info_asteroide)

# --- FIN DEL JUEGO ---
func terminar_juego():
	print("¡Nivel Completado! Generando reporte...")
	
	# 1. Feedback Auditivo de Victoria
	_reproducir_narracion(audio_victoria)
	
	# 2. Feedback Visual (Asteroide Feliz)
	if asteroide_sprite and textura_asteroide_feliz:
		var ancho_viejo = asteroide_sprite.texture.get_width()
		asteroide_sprite.texture = textura_asteroide_feliz
		# Ajuste de escala para que no cambie de tamaño drásticamente
		var ancho_nuevo = asteroide_sprite.texture.get_width()
		if ancho_nuevo > 0:
			var factor = float(ancho_viejo) / float(ancho_nuevo)
			asteroide_sprite.scale *= Vector2(factor, factor)
	
	# Opcional: Bajar volumen de música para oír la victoria
	if musica_fondo: 
		musica_fondo.volume_db = -10 
	
	# 3. Guardar Datos
	var tiempo_fin = Time.get_ticks_msec()
	var segundos_totales = (tiempo_fin - tiempo_inicio) / 1000
	
	# Descomenta cuando tengas tu GlobalSettings listo:
	# GlobalSettings.registrar_partida("Limpieza Asteroide", 100, int(segundos_totales), errores)

	# Esperar a que termine el audio de victoria antes de cambiar (aprox 3 seg)
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://game/historia/Historia3.tscn")
