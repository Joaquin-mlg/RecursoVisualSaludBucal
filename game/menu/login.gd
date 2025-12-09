extends Control

# --- REFERENCIAS UI ---
@onready var input_nombre = $InputNombre
@onready var label_error = $LabelError
@onready var boton_continuar = $BotonContinuar
@onready var teclado_container = $TecladoVirtual # <--- ¡TU NUEVO NODO!

# --- AUDIO ---
@onready var audio_player = $AudioStreamPlayer 

# --- AUDIOS DE ACCESIBILIDAD ---
@export_group("Narración Interfaz")
@export var audio_hover_input: AudioStream
@export var audio_hover_boton: AudioStream
@export var audio_tecla: AudioStream # <--- NUEVO: Sonido al moverte por las letras (ej: "bip")

@export_group("Audios Errores")
@export var audio_error_vacio: AudioStream
@export var audio_error_numeros: AudioStream
@export var audio_exito: AudioStream

var escena_menu = "res://game/menu/main.tscn"
var alfabeto = "ABCDEFGHIJKLMNÑOPQRSTUVWXYZ" # Las letras que aparecerán

func _ready():
	if label_error: label_error.text = ""
	
	# 1. CONEXIONES EXISTENTES
	_conectar_nodo_accesible(input_nombre, audio_hover_input)
	_conectar_nodo_accesible(boton_continuar, audio_hover_boton)

	# --- CORRECCIÓN DEL ERROR ---
	# Verificamos si el nodo existe antes de usarlo
	if teclado_container == null:
		print("🔴 ERROR CRÍTICO: No encuentro el nodo 'TecladoVirtual'.")
		print("👉 SOLUCIÓN: Agrega un GridContainer a la escena y llámalo 'TecladoVirtual'.")
		return # Detenemos aquí para que no explote

	# 2. GENERAR TECLADO VIRTUAL AUTOMÁTICO
	_generar_teclas()

	# 3. AUTO-FOCUS
	if teclado_container.get_child_count() > 0:
		teclado_container.get_child(0).grab_focus()

func _generar_teclas():
	# Doble verificación de seguridad
	if teclado_container == null: return

	# Primero limpiamos por si acaso
	for hijo in teclado_container.get_children():
		hijo.queue_free()
	
	# Creamos botón por cada letra
	for letra in alfabeto:
		var btn = Button.new()
		btn.text = letra
		btn.custom_minimum_size = Vector2(50, 50) # Tamaño del botón
		
		# CONEXIÓN: Al pulsar, escribe la letra
		btn.pressed.connect(func(): 
			input_nombre.text += letra
			_reproducir_audio(audio_tecla) # Feedback sonoro al pulsar
		)
		
		# ACCESIBILIDAD: Al pasar el foco con el control, suena
		btn.focus_entered.connect(func(): _reproducir_audio(audio_tecla))
		btn.mouse_entered.connect(func(): _reproducir_audio(audio_tecla))
		
		# Agregamos al Grid
		teclado_container.add_child(btn)
	
	# --- BOTÓN BORRAR (<-) ---
	var btn_borrar = Button.new()
	btn_borrar.text = "<-"
	btn_borrar.modulate = Color.ORANGE
	btn_borrar.custom_minimum_size = Vector2(50, 50)
	btn_borrar.pressed.connect(_borrar_letra)
	btn_borrar.focus_entered.connect(func(): _reproducir_audio(audio_tecla))
	teclado_container.add_child(btn_borrar)
	
	# --- BOTÓN LISTO (OK) ---
	var btn_ok = Button.new()
	btn_ok.text = "OK"
	btn_ok.modulate = Color.GREEN
	btn_ok.custom_minimum_size = Vector2(50, 50)
	# Al dar OK, saltamos al botón continuar
	btn_ok.pressed.connect(func(): boton_continuar.grab_focus())
	btn_ok.focus_entered.connect(func(): _reproducir_audio(audio_tecla))
	teclado_container.add_child(btn_ok)

func _borrar_letra():
	var texto = input_nombre.text
	if texto.length() > 0:
		input_nombre.text = texto.left(-1) # Quita el último caracter

# --- HELPERS ---
func _conectar_nodo_accesible(nodo, audio):
	if nodo and audio:
		nodo.mouse_entered.connect(func(): _reproducir_audio(audio))
		nodo.focus_entered.connect(func(): _reproducir_audio(audio))

func _on_boton_continuar_pressed():
	# (Tu lógica de validación original sigue aquí igual)
	var nombre = input_nombre.text.strip_edges()
	if nombre == "":
		mostrar_error("¡Debes escribir un nombre!", audio_error_vacio)
		return 
	if _tiene_numeros(nombre):
		mostrar_error("Sin números, por favor.", audio_error_numeros)
		return 
	
	GlobalSettings.nombre_jugador = nombre
	_reproducir_audio(audio_exito)
	if OS.has_feature("mobile"): Input.vibrate_handheld(50)
	Transicion.cambiar_escena(escena_menu)

# --- UTILS ---
func _reproducir_audio(stream: AudioStream):
	if stream == null: return
	if audio_player.playing: audio_player.stop()
	audio_player.stream = stream
	audio_player.play()

func _tiene_numeros(texto: String) -> bool:
	for c in texto:
		if c >= "0" and c <= "9": return true 
	return false

func mostrar_error(mensaje: String, audio_feedback: AudioStream = null):
	if label_error: label_error.text = mensaje
	if audio_feedback: _reproducir_audio(audio_feedback)
	if OS.has_feature("mobile"): Input.vibrate_handheld(400)
