extends Control

# --- REFERENCIAS UI ---
@onready var input_nombre = $InputNombre
@onready var label_error = $LabelError
# Asegúrate de que la ruta al botón sea correcta
@onready var boton_continuar = $BotonContinuar 

# --- NUEVO: REFERENCIA DE AUDIO ---
@onready var audio_player = $AudioStreamPlayer 

# --- AUDIOS DE ACCESIBILIDAD (Arrastra los mp3 aquí) ---
@export_group("Narración Interfaz")
@export var audio_hover_input: AudioStream   # Ej: "Caja de texto: Escribe tu nombre"
@export var audio_hover_boton: AudioStream   # Ej: "Botón: Continuar"

@export_group("Audios Errores")
@export var audio_error_vacio: AudioStream   # "¡Ey! No has escrito nada."
@export var audio_error_numeros: AudioStream # "No uses números, solo letras."
@export var audio_exito: AudioStream         # "¡Genial! Vamos a jugar."

var escena_menu = "res://game/menu/main.tscn"

func _ready():
	# Limpieza inicial
	if label_error:
		label_error.text = ""
	
	# --- CONEXIONES DE AUDIO ---
	# 1. Audio para la caja de texto
	input_nombre.mouse_entered.connect(func(): _reproducir_audio(audio_hover_input))
	
	# 2. Audio para el botón continuar
	boton_continuar.mouse_entered.connect(func(): _reproducir_audio(audio_hover_boton))

func _on_boton_continuar_pressed():
	var nombre = input_nombre.text.strip_edges()
	
	# --- VALIDACIÓN 1: Vacío ---
	if nombre == "":
		mostrar_error("¡Debes escribir un nombre!", audio_error_vacio)
		return 
	
	# --- VALIDACIÓN 2: Números ---
	if _tiene_numeros(nombre):
		mostrar_error("El nombre no puede contener números.", audio_error_numeros)
		return 
	
	# --- ÉXITO ---
	print("Nombre válido: ", nombre)
	GlobalSettings.nombre_jugador = nombre
	
	# Audio de éxito antes de cambiar
	_reproducir_audio(audio_exito)
	
	# Opcional: Vibración cortita de "Éxito" (50ms)
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(50)
	
	# Pequeña pausa opcional
	# await get_tree().create_timer(1.0).timeout
	
	Transicion.cambiar_escena(escena_menu)

# --- FUNCIÓN INTELIGENTE DE AUDIO ---
func _reproducir_audio(stream: AudioStream):
	if stream == null:
		return
		
	if audio_player.playing:
		audio_player.stop()
		
	audio_player.stream = stream
	audio_player.play()

# --- VALIDACIONES ---
func _tiene_numeros(texto: String) -> bool:
	for caracter in texto:
		if caracter >= "0" and caracter <= "9":
			return true 
	return false

func mostrar_error(mensaje: String, audio_feedback: AudioStream = null):
	# 1. Feedback Visual
	print("ERROR: ", mensaje)
	if label_error:
		label_error.text = mensaje
		label_error.modulate = Color.RED
		
		# Animación temblor
		var tween = create_tween()
		tween.tween_property(label_error, "position:x", label_error.position.x + 5, 0.05)
		tween.tween_property(label_error, "position:x", label_error.position.x - 5, 0.05)
		tween.tween_property(label_error, "position:x", label_error.position.x, 0.05)
	
	# 2. Feedback Auditivo (Prioridad)
	if audio_feedback:
		_reproducir_audio(audio_feedback)
		
	# 3. Feedback Táctil (VIBRACIÓN) - NUEVO
	# Solo vibra si detecta que es un dispositivo móvil
	if OS.has_feature("mobile"):
		# 400 milisegundos es una vibración media-larga, ideal para errores
		Input.vibrate_handheld(400)
