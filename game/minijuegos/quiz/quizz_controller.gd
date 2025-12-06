extends Control

# --- REFERENCIAS UI ---
@onready var label_pregunta: RichTextLabel = $PreguntaLabel
@onready var btn_opcion_a: Button = $VBoxContainer/BotonA
@onready var btn_opcion_b: Button = $VBoxContainer/BotonB
@onready var btn_opcion_c: Button = $VBoxContainer/BotonC
@onready var audio_player = $AudioStreamPlayer2D 

# --- VARIABLES DE REPORTE ---
var aciertos: int = 0
var errores: int = 0
var tiempo_inicio: int = 0

var preguntas: Array = [
	{ "texto": "¿Cómo retiramos la suciedad de los asteroides dentales?", "opciones": ["Con un cepillo espacial", "Con un caramelo", "Con un láser"], "correcta": 0 },
	{ "texto": "¿Qué usamos para fortalecer el escudo de los planetas?", "opciones": ["Pasta con flúor", "Chocolate derretido", "Jugo de limón"], "correcta": 0 },
	{ "texto": "¿Cuándo debemos limpiar la galaxia de nuestra boca?", "opciones": ["Solo en Navidad", "Después de comer", "Cuando duela"], "correcta": 1 },
	{ "texto": "¿Qué usamos para limpiar entre los meteoritos?", "opciones": ["Hilo dental", "Cuerda de saltar", "Un lápiz"], "correcta": 0 },
	{ "texto": "¿Quién es el comandante que revisa nuestra salud?", "opciones": ["El Dentista", "El Panadero", "Un Robot"], "correcta": 0 }
]

var indice_actual: int = 0
var pregunta_actual: Dictionary
var quiz_terminado: bool = false

func _ready():
	tiempo_inicio = Time.get_ticks_msec()
	
	# Conexiones
	btn_opcion_a.pressed.connect(func(): _verificar_respuesta(0, btn_opcion_a))
	btn_opcion_b.pressed.connect(func(): _verificar_respuesta(1, btn_opcion_b))
	btn_opcion_c.pressed.connect(func(): _verificar_respuesta(2, btn_opcion_c))
	
	_aplicar_accesibilidad()
	cargar_pregunta()

func _aplicar_accesibilidad():
	var escala = GlobalSettings.tamanio_actual
	label_pregunta.scale = Vector2(escala, escala)
	$VBoxContainer.scale = Vector2(escala, escala)

func cargar_pregunta():
	if indice_actual >= preguntas.size():
		finalizar_quiz()
		return

	pregunta_actual = preguntas[indice_actual]
	
	label_pregunta.text = pregunta_actual["texto"]
	btn_opcion_a.text = "A) " + pregunta_actual["opciones"][0]
	btn_opcion_b.text = "B) " + pregunta_actual["opciones"][1]
	btn_opcion_c.text = "C) " + pregunta_actual["opciones"][2]
	
	_resetear_botones()

func _verificar_respuesta(indice_seleccionado: int, boton_presionado: Button):
	if quiz_terminado: return
	
	if indice_seleccionado == pregunta_actual["correcta"]:
		print("¡Correcto!")
		aciertos += 1
		boton_presionado.modulate = Color.GREEN
		if OS.has_feature("mobile"): Input.vibrate_handheld(50)
		
		_bloquear_todos_botones()
		await get_tree().create_timer(1.5).timeout
		indice_actual += 1
		cargar_pregunta()
		
	else:
		print("Incorrecto")
		errores += 1
		boton_presionado.disabled = true 
		boton_presionado.modulate = Color.RED
		if OS.has_feature("mobile"): Input.vibrate_handheld(300)

func finalizar_quiz():
	quiz_terminado = true
	print("Quiz terminado. Guardando y cambiando de escena...")
	
	# 1. GUARDAR DATOS EN LA LIBRETA
	var tiempo_fin = Time.get_ticks_msec()
	var segundos_totales = (tiempo_fin - tiempo_inicio) / 1000
	var puntaje_final = aciertos * 20 
	
	GlobalSettings.registrar_partida(
		"Quiz Espacial Final", 
		puntaje_final, 
		int(segundos_totales), 
		errores
	)
	
	# 2. CAMBIAR A LA ESCENA DEL REPORTE FINAL
	# ¡Crea esta escena y pon la ruta correcta aquí!
	get_tree().change_scene_to_file("res://game/reporte_final/ReporteFinal.tscn")

func _resetear_botones():
	for btn in [btn_opcion_a, btn_opcion_b, btn_opcion_c]:
		btn.disabled = false
		btn.modulate = Color(1, 1, 1)

func _bloquear_todos_botones():
	btn_opcion_a.disabled = true
	btn_opcion_b.disabled = true
	btn_opcion_c.disabled = true
