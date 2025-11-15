extends Area2D

var siendo_arrastrada = false
var posicion_inicial: Vector2

enum TIPO_HERRAMIENTA {CEPILLO, HILO, ENJUAGUE}
@export var tipo_herramienta: TIPO_HERRAMIENTA

func _ready():
	posicion_inicial = global_position
	add_to_group("herramientas")

func _input_event(viewport, event, shape_idx):
	# Solo detectar cuando se PRESIONA la herramienta
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			empezar_arrastrar()

func empezar_arrastrar():
	siendo_arrastrada = true
	# Capturar el input para seguir moviendo incluso fuera del área
	set_process_input(true)

func _input(event):
	# Si estamos arrastrando, procesar eventos de movimiento
	if siendo_arrastrada:
		if event is InputEventScreenDrag or event is InputEventMouseMotion:
			# Mover la herramienta a la posición del mouse/touch
			global_position = event.position
		
		# Detectar cuando se DEJA DE PRESIONAR (soltar)
		if event is InputEventScreenTouch:
			if not event.pressed:
				terminar_arrastrar()
		elif event is InputEventMouseButton:
			if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				terminar_arrastrar()

func terminar_arrastrar():
	siendo_arrastrada = false
	set_process_input(false)  # Dejar de procesar input
	resetear_posicion()

func resetear_posicion():
	# Crear un tween para animar el regreso a posición inicial
	var tween = create_tween()
	tween.tween_property(self, "global_position", posicion_inicial, 0.3)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
