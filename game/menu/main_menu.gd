extends Node2D

# --- CONFIGURACIÓN DE NAVEGACIÓN ---
@export_group("Navegación")
@export_file("*.tscn") var escena_juego = "res://game/historia/Historia1.tscn"
@export_file("*.tscn") var escena_ajustes = "res://game/menu/Ajustes.tscn"
@export_file("*.tscn") var escena_login = "res://game/menu/Login.tscn"

# --- REFERENCIAS GENERALES ---
@export_group("Referencias Generales")
# ARRASTRA AQUÍ TUS 3 BOTONES EN EL INSPECTOR (Para que se animen todos)
@export var lista_botones: Array[Button] 
@onready var musica_fondo = $MusicaFondo
@onready var sfx_click = $SFXClick
@onready var audio_narrador = $AudioNarrador # <--- NUEVO: Nodo para la voz

@export_group("Referencias UI") 
@export var label_saludo: Label 

# --- CONFIGURACIÓN DE AUDIO NARRATIVO ---
@export_group("Asignación Audio y Botones")
# Aquí asignamos cada botón ESPECÍFICO con su audio para saber qué decir
@export_subgroup("Botón Jugar")
@export var ref_btn_jugar: Button
@export var audio_btn_jugar: AudioStream

@export_subgroup("Botón Ajustes")
@export var ref_btn_ajustes: Button
@export var audio_btn_ajustes: AudioStream

@export_subgroup("Botón Salir")
@export var ref_btn_salir: Button
@export var audio_btn_salir: AudioStream

@export_subgroup("Botón Login/Nombre")
@export var ref_btn_login: Button
@export var audio_btn_login: AudioStream

@export_subgroup("Bienvenida")
@export var audio_bienvenida_menu: AudioStream # "Hola viajero, selecciona una opción"

# --- CONFIGURACIÓN VISUAL (Animación) ---
@export_group("Animación Botones")
@export var factor_crecimiento: float = 1.1
@export var tiempo_animacion: float = 0.1

func _ready():
	_actualizar_saludo()
	
	# 1. Música
	if musica_fondo and not musica_fondo.playing:
		musica_fondo.play()
	
	# 2. Configurar ANIMACIONES para la lista completa
	for boton in lista_botones:
		_configurar_animacion_boton(boton)
	
	# 3. Configurar AUDIOS específicos (Mouse Hover / Dedo)
	_conectar_audio_boton(ref_btn_jugar, audio_btn_jugar)
	_conectar_audio_boton(ref_btn_ajustes, audio_btn_ajustes)
	_conectar_audio_boton(ref_btn_salir, audio_btn_salir)
	_conectar_audio_boton(ref_btn_login, audio_btn_login)
	
	# 4. Escuchar cambios de accesibilidad
	GlobalSettings.configuracion_cambiada.connect(_actualizar_todos_los_botones)
	
	# Reproducir bienvenida al entrar al menú
	_reproducir_narracion(audio_bienvenida_menu)

# --- CONFIGURACIÓN DE ANIMACIÓN ---
func _configurar_animacion_boton(btn: Button):
	if btn == null: return
	
	# Ajustar pivote para que crezca desde el centro
	btn.pivot_offset = btn.size / 2
	
	# Conectar las señales de animación
	btn.mouse_entered.connect(_animar_crecer.bind(btn))
	btn.mouse_exited.connect(_animar_volver.bind(btn))
	btn.button_down.connect(_animar_pulsar.bind(btn))
	btn.button_up.connect(_animar_soltar.bind(btn))
	
	# Aplicar tamaño inicial
	_aplicar_tamano_accesible(btn)

# --- CONFIGURACIÓN DE AUDIO ---
func _conectar_audio_boton(btn: Button, audio: AudioStream):
	# Solo conectamos si el botón y el audio existen
	if btn and audio:
		btn.mouse_entered.connect(func(): _reproducir_narracion(audio))

func _reproducir_narracion(stream: AudioStream):
	if stream == null: return
	
	# Si ya está hablando, lo callamos para decir lo nuevo
	if audio_narrador.playing:
		audio_narrador.stop()
		
	audio_narrador.stream = stream
	audio_narrador.play()

func _actualizar_todos_los_botones():
	for boton in lista_botones:
		_aplicar_tamano_accesible(boton)

func _aplicar_tamano_accesible(btn: Button):
	if btn == null: return
	var tam = GlobalSettings.tamanio_actual
	btn.scale = Vector2(tam, tam)
	btn.pivot_offset = btn.size / 2 

# --- LÓGICA DE ANIMACIÓN GENÉRICA ---
func _animar_crecer(btn: Button):
	var escala_base = Vector2(GlobalSettings.tamanio_actual, GlobalSettings.tamanio_actual)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(btn, "scale", escala_base * factor_crecimiento, tiempo_animacion)

func _animar_volver(btn: Button):
	var escala_base = Vector2(GlobalSettings.tamanio_actual, GlobalSettings.tamanio_actual)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(btn, "scale", escala_base, tiempo_animacion)

func _animar_pulsar(btn: Button):
	var escala_base = Vector2(GlobalSettings.tamanio_actual, GlobalSettings.tamanio_actual)
	var tween = create_tween()
	tween.tween_property(btn, "scale", escala_base * 0.95, 0.05)

func _animar_soltar(btn: Button):
	if btn.is_hovered():
		_animar_crecer(btn)
	else:
		_animar_volver(btn)

# --- LÓGICA DE NAVEGACIÓN ---
func _on_button_iniciar_pressed():
	_ir_a_escena(escena_juego, "Iniciando juego...")

func _on_button_configuracion_pressed():
	_ir_a_escena(escena_ajustes, "Ajustes...")

func _on_button_salir_pressed():
	print("Saliendo...")
	_feedback_sonoro()
	# Pequeña espera para oír el click antes de cerrar
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()

func _on_button_nombre_pressed() -> void:
	# GlobalSettings.nombre_jugador = "" 
	_ir_a_escena(escena_login, "Regresando al Login...")

# Función auxiliar para navegar
func _ir_a_escena(ruta: String, mensaje: String):
	print(mensaje)
	_feedback_sonoro()
	if ruta:
		Transicion.cambiar_escena(ruta)
	else:
		print("ERROR: Ruta de escena no asignada")

func _feedback_sonoro():
	# Solo reproduce el sonido, SIN vibración
	if sfx_click: sfx_click.play()

func _actualizar_saludo():
	if label_saludo:
		if GlobalSettings.nombre_jugador != "":
			label_saludo.text = "Hola, " + GlobalSettings.nombre_jugador
		else:
			label_saludo.text = "Hola, Viajero"
