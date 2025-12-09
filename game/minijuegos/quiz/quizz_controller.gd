extends Node2D

# --- REFERENCIAS UI ---
@onready var label_pregunta: RichTextLabel = $CajonPreguntas/PreguntaLabel

# Referenciamos al PADRE (la imagen visual) para cambiar colores
@onready var visual_a: TextureRect = $BotonA
@onready var visual_b: TextureRect = $BotonB
@onready var visual_c: TextureRect = $BotonC

# Referenciamos al HIJO (el botón invisible) para detectar el clic
@onready var btn_a: Button = $BotonA/Hitbox
@onready var btn_b: Button = $BotonB/Hitbox
@onready var btn_c: Button = $BotonC/Hitbox

@onready var label_a: Label = $BotonA/Hitbox/Label
@onready var label_b: Label = $BotonB/Hitbox/Label
@onready var label_c: Label = $BotonC/Hitbox/Label

@onready var audio_player = $AudioStreamPlayer2D 

# --- VARIABLES ---
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
	
	# Conectamos la señal del botón invisible (Hitbox)
	# Pasamos como argumentos: el índice y EL NODO VISUAL (el padre) para pintarlo
	btn_a.pressed.connect(func(): _verificar_respuesta(0, btn_a, visual_a))
	btn_b.pressed.connect(func(): _verificar_respuesta(1, btn_b, visual_b))
	btn_c.pressed.connect(func(): _verificar_respuesta(2, btn_c, visual_c))
	
	_aplicar_accesibilidad()
	cargar_pregunta()

func _aplicar_accesibilidad():
	var escala = GlobalSettings.tamanio_actual
	label_pregunta.scale = Vector2(escala, escala)
	# Escalamos los contenedores visuales
	visual_a.scale = Vector2(escala, escala)
	visual_b.scale = Vector2(escala, escala)
	visual_c.scale = Vector2(escala, escala)

func cargar_pregunta():
	if indice_actual >= preguntas.size():
		finalizar_quiz()
		return

	pregunta_actual = preguntas[indice_actual]
	
	label_pregunta.text = pregunta_actual["texto"]
	
	# Asignamos texto a los labels que están dentro de las hitboxes
	label_a.text = "A) " + pregunta_actual["opciones"][0]
	label_b.text = "B) " + pregunta_actual["opciones"][1]
	label_c.text = "C) " + pregunta_actual["opciones"][2]
	
	_resetear_botones()

# AHORA RECIBE 3 ARGUMENTOS: Indice, El Botón (para bloquearlo), La Imagen (para pintarla)
func _verificar_respuesta(indice_seleccionado: int, boton_presionado: Button, imagen_visual: TextureRect):
	if quiz_terminado: return
	
	if indice_seleccionado == pregunta_actual["correcta"]:
		print("¡Correcto!")
		aciertos += 1
		# Pintamos la imagen visual, no el botón invisible
		imagen_visual.modulate = Color.GREEN
		
		if OS.has_feature("mobile"): Input.vibrate_handheld(50)
		
		_bloquear_todos_botones()
		await get_tree().create_timer(1.5).timeout
		indice_actual += 1
		cargar_pregunta()
		
	else:
		print("Incorrecto")
		errores += 1
		# Bloqueamos el botón invisible
		boton_presionado.disabled = true 
		# Pintamos la imagen visual de rojo
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
	# Reseteamos lógica (botones) y visuales (imágenes)
	for btn in [btn_a, btn_b, btn_c]:
		btn.disabled = false
	
	for visual in [visual_a, visual_b, visual_c]:
		visual.modulate = Color(1, 1, 1)

func _bloquear_todos_botones():
	btn_a.disabled = true
	btn_b.disabled = true
	btn_c.disabled = true
