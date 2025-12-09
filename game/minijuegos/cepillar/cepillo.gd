extends Area2D

# --- VARIABLES EXISTENTES ---
var is_dragging = false
var drag_offset = Vector2.ZERO
var is_cleaning = false 
var posicion_inicial: Vector2 
var tween: Tween 

# --- NUEVO PARA MANDO PS4 ---
var mouse_sobre_mi = false # Bandera para saber si el cursor virtual está encima

# --- ACCESIBILIDAD ---
@export_group("Accesibilidad")
@export var audio_descripcion: AudioStream # "Soy el cepillo..."

# Buscamos al narrador en el nivel principal
@onready var nivel_principal = get_tree().get_first_node_in_group("nivel_cepillar")

func _ready():
	posicion_inicial = global_position 
	
	# --- CONEXIONES ---
	# Usamos estas señales para saber si el cursor (mouse o virtual) está encima
	mouse_entered.connect(_on_mouse_enter)
	mouse_exited.connect(_on_mouse_exit)

# --- DETECCIÓN DE CURSOR (MOUSE O MANDO) ---
func _on_mouse_enter():
	mouse_sobre_mi = true
	_decir_quien_soy() # Audio descriptivo

func _on_mouse_exit():
	mouse_sobre_mi = false

func _decir_quien_soy():
	if not is_dragging and nivel_principal and nivel_principal.has_method("_reproducir_narracion"):
		nivel_principal._reproducir_narracion(audio_descripcion)

# --- INPUT HÍBRIDO (CLAVE PARA QUE FUNCIONE EL MANDO) ---
func _input(event):
	# 1. SOLTAR (Mouse suelta clic O Mando suelta botón X)
	if is_dragging:
		if event.is_action_released("click_mando") or (event is InputEventMouseButton and not event.pressed):
			is_cleaning = false
			is_dragging = false
			regresar_suavemente() 
			return
	
	# 2. AGARRAR CON MANDO (Botón X / click_mando)
	# Si el cursor está encima Y presionas el botón asignado
	if mouse_sobre_mi and Input.is_action_just_pressed("click_mando"):
		iniciar_arrastre()

# --- INPUT ORIGINAL DE MOUSE (Respaldo) ---
func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		iniciar_arrastre()

# --- FUNCIÓN COMÚN DE ARRASTRE ---
func iniciar_arrastre():
	if tween and tween.is_running(): tween.kill()
	is_dragging = true
	# Calculamos el offset para que no "salte" al centro del cursor
	drag_offset = global_position - get_global_mouse_position()
	
	# Vibración pequeña al agarrar
	if OS.has_feature("mobile"): Input.vibrate_handheld(50)

# --- PROCESO ---
func _process(delta):
	# Movimiento: Seguimos al mouse (o al cursor virtual)
	if is_dragging:
		global_position = get_global_mouse_position() + drag_offset
		
		# Limpieza (Solo si estamos sobre el asteroide)
		if is_cleaning:
			var asteroide_node = get_tree().root.get_node("Cepillar/Asteroide") 
			if asteroide_node:
				asteroide_node.recibir_limpieza_degradada(delta)
			
			# FEEDBACK HÁPTICO
			if OS.has_feature("mobile"):
				Input.vibrate_handheld(20)

func regresar_suavemente():
	tween = create_tween()
	tween.tween_property(self, "global_position", posicion_inicial, 0.3)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)

func _on_area_entered(area: Area2D) -> void:
	if area.name == "Asteroide":
		is_cleaning = true

func _on_area_exited(area: Area2D) -> void:
	if area.name == "Asteroide":
		is_cleaning = false
