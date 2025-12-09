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

# --- AUDIO (Desactivado por ahora) ---
@onready var audio_player = $AudioStreamPlayer2D 

# --- VARIABLES PARA ALTO CONTRASTE ---
@export_group("Accesibilidad")
@export var textura_boton_ac: Texture2D   # <--- ¡ARRASTRA LA TEXTURA AMARILLA AQUÍ!
@export var textura_cajon_ac: Texture2D   # <--- ¡ARRASTRA LA TEXTURA AMARILLA AQUÍ!

# Guardar texturas originales
var _tex_orig_a: Texture2D
var _tex_orig_b: Texture2D
var _tex_orig_c: Texture2D
var _tex_orig_cajon: Texture2D

# --- VARIABLES JUEGO ---
var aciertos: int = 0
var errores: int = 0
var tiempo_inicio: int = 0

var preguntas: Array = [
	{ "texto": "¿Cómo retiramos la suciedad de los asteroides?", "opciones": ["Con enjuague bucal", "Con un caramelo", "Con un láser"], "correcta": 0 },
	{ "texto": "¿Qué usamos para quitar el polvo de los planetas?", "opciones": ["cepillo de dientes", "Chocolate derretido", "Jugo de limón"], "correcta": 0 },
	{ "texto": "¿Cuándo debemos limpiar nuestros dientes?", "opciones": ["Solo en Navidad", "Después de comer", "Cuando duela"], "correcta": 1 },
	{ "texto": "¿Qué usamos para quitar asteroides y satelites pegados?", "opciones": ["Hilo dental", "Cuerda de saltar", "Un lápiz"], "correcta": 0 },
	{ "texto": "¿Que le gusta a Astillin la ardilla de las caries", "opciones": ["Chocolate", "Cepillos", "capas rojas"], "correcta": 0 }
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
	
	# 2. Conectar lógica de juego
	btn_a.pressed.connect(func(): _verificar_respuesta(0, btn_a, visual_a))
	btn_b.pressed.connect(func(): _verificar_respuesta(1, btn_b, visual_b))
	btn_c.pressed.connect(func(): _verificar_respuesta(2, btn_c, visual_c))
	
	# 3. Conectar Accesibilidad
	GlobalSettings.high_contrast_changed.connect(_actualizar_texturas_ac)
	
	# -------------------------------------------------------------
	# ¡AQUÍ ESTÁ EL CAMBIO! FORZAMOS A 'TRUE' DIRECTAMENTE
	# -------------------------------------------------------------
	print("!!! FORZANDO MODO ACCESIBILIDAD ACTIVADO !!!")
	
	cargar_pregunta()

func _actualizar_texturas_ac(activo: bool):
	print("Aplicando texturas de accesibilidad: ", activo)
	
	if activo:
		# --- MODO ACTIVADO ---
		
		# Verificación de seguridad
		if textura_boton_ac == null or textura_cajon_ac == null:
			print("ERROR ROJO: ¡FALTAN LAS TEXTURAS EN EL INSPECTOR!")
			return

		# Cambio visual
		visual_a.texture = textura_boton_ac
		visual_b.texture = textura_boton_ac
		visual_c.texture = textura_boton_ac
		visual_cajon.texture = textura_cajon_ac
		
		# Cambio de color de letra a NEGRO (para que se vea en el amarillo)
		label_pregunta.add_theme_color_override("default_color", Color.BLACK)
		label_a.add_theme_color_override("font_color", Color.BLACK)
		label_b.add_theme_color_override("font_color", Color.BLACK)
		label_c.add_theme_color_override("font_color", Color.BLACK)
		
	else:
		# --- MODO DESACTIVADO ---
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
	label_pregunta.text = pregunta_actual["texto"]
	label_a.text = "A) " + pregunta_actual["opciones"][0]
	label_b.text = "B) " + pregunta_actual["opciones"][1]
	label_c.text = "C) " + pregunta_actual["opciones"][2]
	
	_resetear_botones()

func _verificar_respuesta(indice_seleccionado: int, boton_presionado: Button, imagen_visual: TextureRect):
	if quiz_terminado: return
	
	if indice_seleccionado == pregunta_actual["correcta"]:
		aciertos += 1
		imagen_visual.modulate = Color.GREEN
		if OS.has_feature("mobile"): Input.vibrate_handheld(50)
		_bloquear_todos_botones()
		await get_tree().create_timer(1.5).timeout
		indice_actual += 1
		cargar_pregunta()
	else:
		errores += 1
		boton_presionado.disabled = true 
		imagen_visual.modulate = Color.RED
		if OS.has_feature("mobile"): Input.vibrate_handheld(300)

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
