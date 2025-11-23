extends Control

# --- CAMBIOS AQUÍ ---
# Ajustado a tu imagen: Los nodos son hijos directos, no están dentro del Panel
# Ajustado a tus nombres: Button, Button2, Button3

@onready var label_pregunta: RichTextLabel = $PreguntaLabel
@onready var btn_opcion_a: Button = $VBoxContainer/BotonA
@onready var btn_opcion_b: Button = $VBoxContainer/BotonB
@onready var btn_opcion_c: Button = $VBoxContainer/BotonC

# Cambia esto si decides usar el AudioStreamPlayer normal (recomendado)
# Si dejas el 2D, asegúrate de que esté cerca de la cámara o Listener.
@onready var audio_player = $AudioStreamPlayer2D 

# --- RESTO DEL CÓDIGO IGUAL ---

var preguntas: Array = [
	{
		"texto": "¿Cómo retiramos la suciedad de los asteroides dentales?",
		"opciones": ["Con un cepillo espacial", "Con un caramelo", "Con un láser"],
		"correcta": 0
	},
	{
		"texto": "¿Qué usamos para fortalecer el escudo de los planetas?",
		"opciones": ["Pasta con flúor", "Chocolate derretido", "Jugo de limón"],
		"correcta": 0
	},
	{
		"texto": "¿Cuándo debemos limpiar la galaxia de nuestra boca?",
		"opciones": ["Solo en Navidad", "Después de comer", "Cuando duela"],
		"correcta": 1
	},
	{
		"texto": "¿Qué usamos para limpiar entre los meteoritos?",
		"opciones": ["Hilo dental", "Cuerda de saltar", "Un lápiz"],
		"correcta": 0
	},
	{
		"texto": "¿Quién es el comandante que revisa nuestra salud?",
		"opciones": ["El Dentista", "El Panadero", "Un Robot"],
		"correcta": 0
	}
]

var indice_actual: int = 0
var pregunta_actual: Dictionary
var quiz_terminado: bool = false

# SONIDOS (Asegúrate de tenerlos o comenta estas líneas si da error al cargar)
#var sfx_correcto = preload("res://audio/efectos/success.wav") 
#var sfx_error = preload("res://audio/efectos/error.wav")
#var sfx_final = preload("res://audio/efectos/level_complete.wav")

func _ready():
	# Conexiones
	btn_opcion_a.pressed.connect(func(): _verificar_respuesta(0, btn_opcion_a))
	btn_opcion_b.pressed.connect(func(): _verificar_respuesta(1, btn_opcion_b))
	btn_opcion_c.pressed.connect(func(): _verificar_respuesta(2, btn_opcion_c))
	
	cargar_pregunta()

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
	
	# Accesibilidad: Leer pregunta
	print("Narrando: " + pregunta_actual["texto"])

func _verificar_respuesta(indice_seleccionado: int, boton_presionado: Button):
	if quiz_terminado: return
	
	if indice_seleccionado == pregunta_actual["correcta"]:
		print("¡Correcto!")
#		reproducir_sonido(sfx_correcto)
		boton_presionado.modulate = Color(0, 1, 0) # Verde
		
		_bloquear_todos_botones()
		await get_tree().create_timer(1.5).timeout
		
		indice_actual += 1
		cargar_pregunta()
		
	else:
		print("Incorrecto")
	#	reproducir_sonido(sfx_error)
		boton_presionado.disabled = true # Bloqueo solicitado
		boton_presionado.modulate = Color(0.3, 0.3, 0.3) # Gris oscuro
		
	#	if DisplayServer.has_feature(DisplayServer.FEATURE_VIBRATION):
	#		Input.vibrate_handheld(500)

func finalizar_quiz():
	quiz_terminado = true
	label_pregunta.text = "¡Misión Cumplida! Universo limpio."
	_bloquear_todos_botones()
	#reproducir_sonido(sfx_final)

func _resetear_botones():
	for btn in [btn_opcion_a, btn_opcion_b, btn_opcion_c]:
		btn.disabled = false
		btn.modulate = Color(1, 1, 1)

func _bloquear_todos_botones():
	btn_opcion_a.disabled = true
	btn_opcion_b.disabled = true
	btn_opcion_c.disabled = true

func reproducir_sonido(stream):
	if stream:
		audio_player.stream = stream
		audio_player.play()
