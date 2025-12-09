extends Area2D

signal objeto_clasificado(es_correcto: bool)

# --- VARIABLES INTERNAS ---
var es_bueno: bool = false
var audio_identificacion: AudioStream
var nombre_objeto: String = ""

var dragging = false
var drag_offset = Vector2()
var posicion_inicial = Vector2()

# --- NUEVO PARA MANDO PS4 ---
var mouse_sobre_mi = false # ¿El cursor virtual está encima?

var nivel_principal: Node2D

func _ready():
	posicion_inicial = global_position
	nivel_principal = get_tree().get_first_node_in_group("nivel_clasificacion")
	
	# --- CONEXIONES PARA DETECTAR EL CURSOR ---
	mouse_entered.connect(_on_mouse_enter)
	mouse_exited.connect(_on_mouse_exit)

# --- DETECCIÓN DE CURSOR ---
func _on_mouse_enter():
	mouse_sobre_mi = true
	# Al poner el cursor encima, dice el nombre
	if not dragging:
		_solicitar_narracion()

func _on_mouse_exit():
	mouse_sobre_mi = false

# --- INPUT HÍBRIDO (MANDO + MOUSE) ---
func _input(event):
	# 1. SOLTAR EL OBJETO
	if dragging:
		# Si sueltas el botón X del mando O sueltas el clic izquierdo
		if event.is_action_released("click_mando") or (event is InputEventMouseButton and not event.pressed):
			dragging = false
			verificar_clasificacion()
			return

	# 2. AGARRAR EL OBJETO CON MANDO (Botón X)
	# Si el cursor está encima Y presionas X
	if mouse_sobre_mi and Input.is_action_just_pressed("click_mando"):
		iniciar_arrastre()

# --- INPUT DE MOUSE (Respaldo para PC) ---
func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		iniciar_arrastre()

# --- LÓGICA DE ARRASTRE ---
func iniciar_arrastre():
	dragging = true
	# Calculamos la diferencia para que no salte al centro
	drag_offset = global_position - get_global_mouse_position()
	
	# Vibración al agarrar
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(50)

func _process(_delta):
	if dragging:
		# El objeto sigue al mouse (o al cursor virtual del mando)
		global_position = get_global_mouse_position() + drag_offset

# --- CONFIGURACIÓN (Viene del Spawner) ---
func configurar(datos):
	es_bueno = datos["es_bueno"]
	nombre_objeto = datos["nombre"]
	
	# Cargar imagen
	var tex = load(datos["texture_path"])
	$Sprite2D.texture = tex 
	
	# Cargar Audio (Manejo robusto)
	if datos.has("audio_nombre"):
		var data = datos["audio_nombre"]
		if data is AudioStream:
			audio_identificacion = data
		elif data is String:
			audio_identificacion = load(data)

# --- NARRACIÓN ---
func _solicitar_narracion():
	if audio_identificacion and nivel_principal:
		nivel_principal._reproducir_voz(audio_identificacion)

# --- LÓGICA DE CLASIFICACIÓN ---
func verificar_clasificacion():
	var areas = get_overlapping_areas()
	
	for area in areas:
		if area.is_in_group("zona_mochila"): 
			if es_bueno: procesar_acierto()
			else: procesar_error()
			return
			
		elif area.is_in_group("zona_basura"): 
			if not es_bueno: procesar_acierto()
			else: procesar_error()
			return
	
	# Si no tocó nada, regresa
	regresar_a_inicio()

func procesar_acierto():
	emit_signal("objeto_clasificado", true)
	queue_free()

func procesar_error():
	emit_signal("objeto_clasificado", false)
	regresar_a_inicio()

func regresar_a_inicio():
	var tween = create_tween()
	tween.tween_property(self, "global_position", posicion_inicial, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
