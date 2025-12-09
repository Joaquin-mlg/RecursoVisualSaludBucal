extends Node2D

# --- REFERENCIAS UI ---
@onready var label_pregunta: RichTextLabel = $CajonPreguntas/PreguntaLabel
@onready var visual_cajon: TextureRect = $CajonPreguntas

# Referencias visuales (TextureRect)
@onready var visual_a: TextureRect = $BotonA
@onready var visual_b: TextureRect = $BotonB
@onready var visual_c: TextureRect = $BotonC

# Referencias de interacción (Button invisible)
@onready var btn_a: Button = $BotonA/Hitbox
@onready var btn_b: Button = $BotonB/Hitbox
@onready var btn_c: Button = $BotonC/Hitbox

# Referencias de texto
@onready var label_a: Label = $BotonA/Hitbox/Label
@onready var label_b: Label = $BotonB/Hitbox/Label
@onready var label_c: Label = $BotonC/Hitbox/Label

# --- AUDIO ---
@onready var audio_player = $AudioStreamPlayer2D 

# --- VARIABLES PARA ALTO CONTRASTE ---
@export_group("Accesibilidad Visual")
@export var textura_boton_ac: Texture2D   
@export var textura_cajon_ac: Texture2D   

# --- VARIABLES PARA AUDIO (FEEDBACK) ---
@export_group("Accesibilidad Auditiva")
@export var audio_acierto: AudioStream # Sonido de "Ting" o "¡Muy bien!"
@export var audio_error: AudioStream   # Sonido de "Buzz" o "Intenta de nuevo"

# Guardar texturas originales
var _tex_orig_a: Texture2D
var _tex_orig_b: Texture2D
var _tex_orig_c: Texture2D
var _tex_orig_cajon: Texture2D

# --- VARIABLES JUEGO ---
var aciertos: int = 0
var errores: int = 0
var tiempo_inicio: int = 0

# Variables para guardar los audios de la ronda actual
var audio_actual_pregunta: AudioStream
var audios_actuales_opciones: Array = [null, null, null]

# --- BASE DE DATOS DE PREGUNTAS ---
var preguntas: Array = [
	{ 
		"texto": "¿Cómo retiramos la suciedad de los asteroides?", 
		"opciones": ["Con enjuague bucal", "Con un caramelo", "Con un láser"], 
		"correcta": 0,
		"audio_preg": preload("res://game/audio/narraciones/P1.mp3"), 
		"audios_opc": [
			preload("res://game/audio/narraciones/Enjuague bucal.mp3"),
			preload("res://game/audio/narraciones/Chupete.mp3"),
			preload("res://game/audio/narraciones/R13.mp3")
		]
	},
	{ 
		"texto": "¿Qué usamos para quitar el polvo de los planetas?", 
		"opciones": ["cepillo de dientes", "Chocolate derretido", "Jugo de limón"], 
		"correcta": 0,
		"audio_preg": preload("res://game/audio/narraciones/P2.mp3"),
		"audios_opc": [
			preload("res://game/audio/narraciones/Cepillo.mp3"),
			preload("res://game/audio/narraciones/Chocolate.mp3"),
			preload("res://game/audio/narraciones/R23.mp3")
		]
	},
	{ 
		"texto": "¿Cuándo debemos limpiar nuestros dientes?", 
		"opciones": ["Solo en Navidad", "Después de comer", "Cuando duela"], 
		"correcta": 1,
		"audio_preg": preload("res://game/audio/narraciones/P3.mp3"),
		"audios_opc": [
			preload("res://game/audio/narraciones/R3.mp3"),
			preload("res://game/audio/narraciones/R32.mp3"),
			preload("res://game/audio/narraciones/R33.mp3")
		]
	},
	{ 
		"texto": "¿Qué usamos para quitar asteroides y satelites pegados?", 
		"opciones": ["Hilo dental", "Cuerda de saltar", "Un lápiz"], 
		"correcta": 0,
		"audio_preg": preload("res://game/audio/narraciones/P4.mp3"),
		"audios_opc": [
			preload("res://game/audio/narraciones/Hilodental.mp3"),
			preload("res://game/audio/narraciones/R41.mp3"),
			preload("res://game/audio/narraciones/R42.mp3")
		]
	},
	{ 
		"texto": "¿Que le gusta a Astillin la ardilla de las caries", 
		"opciones": ["Chocolate", "Cepillos", "Nubes"], 
		"correcta": 0,
		"audio_preg": preload("res://game/audio/narraciones/p5.mp3"),
		"audios_opc": [
			preload("res://game/audio/narraciones/Chocolate.mp3"),
			preload("res://game/audio/narraciones/Cepillo.mp3"),
			preload("res://game/audio/narraciones/r5.mp3")
		]
	}
]

var indice_actual: int = 0
var pregunta_actual: Dictionary
var quiz_terminado: bool = false

func _ready():
	tiempo_inicio = Time.get_ticks_msec()
	
	# 1. Guardar originales
	_tex_orig_a = visual_a.texture
	_tex_orig_b = visual_b.texture
	_tex_orig_c = visual_c.texture
	_tex_orig_cajon = visual_cajon.texture
	
	# 2. Conectar lógica de juego (CLIC)
	btn_a.pressed.connect(func(): _verificar_respuesta(0, btn_a, visual_a))
	btn_b.pressed.connect(func(): _verificar_respuesta(1, btn_b, visual_b))
	btn_c.pressed.connect(func(): _verificar_respuesta(2, btn_c, visual_c))
	
	# 3. Conectar Accesibilidad de Audio (MOUSE ENTER / DEDO)
	# MODIFICADO: Solo suena si el botón NO está deshabilitado
	btn_a.mouse_entered.connect(func(): 
		if not btn_a.disabled: _reproducir_narracion(audios_actuales_opciones[0]))
		
	btn_b.mouse_entered.connect(func(): 
		if not btn_b.disabled: _reproducir_narracion(audios_actuales_opciones[1]))
		
	btn_c.mouse_entered.connect(func(): 
		if not btn_c.disabled: _reproducir_narracion(audios_actuales_opciones[2]))
	
	# 4. Conectar Accesibilidad Visual
	GlobalSettings.high_contrast_changed.connect(_actualizar_texturas_ac)
	_actualizar_texturas_ac(GlobalSettings.alto_contraste_activo)
	
	cargar_pregunta()

func _actualizar_texturas_ac(activo: bool):
	if activo:
		if textura_boton_ac and textura_cajon_ac:
			visual_a.texture = textura_boton_ac
			visual_b.texture = textura_boton_ac
			visual_c.texture = textura_boton_ac
			visual_cajon.texture = textura_cajon_ac
			
			label_pregunta.add_theme_color_override("default_color", Color.BLACK)
			label_a.add_theme_color_override("font_color", Color.BLACK)
			label_b.add_theme_color_override("font_color", Color.BLACK)
			label_c.add_theme_color_override("font_color", Color.BLACK)
	else:
		visual_a.texture = _tex_orig_a
		visual_b.texture = _tex_orig_b
		visual_c.texture = _tex_orig_c
		visual_cajon.texture = _tex_orig_cajon
		
		label_pregunta.remove_theme_color_override("default_color")
		label_a.remove_theme_color_override("font_color")
		label_b.remove_theme_color_override("font_color")
		label_c.remove_theme_color_override("font_color")

func cargar_pregunta():
	if indice_actual >= preguntas.size():
		finalizar_quiz()
		return

	pregunta_actual = preguntas[indice_actual]
	
	# 1. Textos Visuales
	label_pregunta.text = pregunta_actual["texto"]
	label_a.text = "A) " + pregunta_actual["opciones"][0]
	label_b.text = "B) " + pregunta_actual["opciones"][1]
	label_c.text = "C) " + pregunta_actual["opciones"][2]
	
	# 2. Cargar Audios
	audio_actual_pregunta = pregunta_actual.get("audio_preg")
	var lista_audios = pregunta_actual.get("audios_opc")
	if lista_audios and lista_audios.size() == 3:
		audios_actuales_opciones = lista_audios
	else:
		audios_actuales_opciones = [null, null, null]
	
	# --- LÓGICA DE DELAY Y PROTECCIÓN ---
	# Bloqueamos los botones antes de hablar para que el niño no interrumpa
	_bloquear_todos_botones()
	
	# 3. Reproducir Pregunta y ESPERAR a que termine
	if audio_actual_pregunta:
		_reproducir_narracion(audio_actual_pregunta)
		
		# Esperamos a que el audio termine antes de permitir jugar
		# "finished" es la señal que emite el AudioStreamPlayer al terminar
		if audio_player.playing:
			await audio_player.finished
	
	# Solo después de que el narrador se calla, activamos los botones
	_resetear_botones()

func _verificar_respuesta(indice_seleccionado: int, boton_presionado: Button, imagen_visual: TextureRect):
	if quiz_terminado: return
	
	if audio_player.playing: audio_player.stop()
	
	if indice_seleccionado == pregunta_actual["correcta"]:
		# Acierto
		aciertos += 1
		imagen_visual.modulate = Color.GREEN
		_reproducir_narracion(audio_acierto)
		if OS.has_feature("mobile"): Input.vibrate_handheld(50)
		
		_bloquear_todos_botones()
		await get_tree().create_timer(1.5).timeout
		indice_actual += 1
		cargar_pregunta()
	else:
		# Error
		errores += 1
		boton_presionado.disabled = true 
		imagen_visual.modulate = Color.RED
		_reproducir_narracion(audio_error)
		if OS.has_feature("mobile"): Input.vibrate_handheld(400)

func _reproducir_narracion(stream: AudioStream):
	if stream == null: return
	
	if audio_player.playing:
		audio_player.stop()
		
	audio_player.stream = stream
	audio_player.play()

func finalizar_quiz():
	quiz_terminado = true
	var tiempo_fin = Time.get_ticks_msec()
	var segundos_totales = (tiempo_fin - tiempo_inicio) / 1000
	var puntaje_final = aciertos * 20 
	GlobalSettings.registrar_partida("Quiz Espacial Final", puntaje_final, int(segundos_totales), errores)
	Transicion.cambiar_escena("res://game/historia/Historia5.tscn")

func _resetear_botones():
	for btn in [btn_a, btn_b, btn_c]:
		btn.disabled = false
	for visual in [visual_a, visual_b, visual_c]:
		visual.modulate = Color(1, 1, 1)

func _bloquear_todos_botones():
	btn_a.disabled = true
	btn_b.disabled = true
	btn_c.disabled = true
