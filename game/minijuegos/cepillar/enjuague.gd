extends Area2D

# --- VARIABLES EXISTENTES ---
var is_dragging = false
var drag_offset = Vector2.ZERO
var is_spraying = false 
var posicion_inicial: Vector2 
var tween: Tween 

# --- NUEVO PARA MANDO PS4 ---
var mouse_sobre_mi = false # ¿El cursor virtual está encima?

# --- ACCESIBILIDAD ---
@export_group("Accesibilidad")
@export var audio_descripcion: AudioStream # "Soy el enjuague..."

@onready var nivel_principal = get_tree().get_first_node_in_group("nivel_cepillar")

func _ready():
	posicion_inicial = global_position 
	
	# CONEXIONES HÍBRIDAS (Mouse y Cursor Virtual)
	mouse_entered.connect(_on_mouse_enter)
	mouse_exited.connect(_on_mouse_exit)

# --- DETECCIÓN DE CURSOR ---
func _on_mouse_enter():
	mouse_sobre_mi = true
	_decir_quien_soy() # Audio descriptivo

func _on_mouse_exit():
	mouse_sobre_mi = false

func _decir_quien_soy():
	if not is_dragging and nivel_principal and nivel_principal.has_method("_reproducir_narracion"):
		nivel_principal._reproducir_narracion(audio_descripcion)

# --- INPUT HÍBRIDO (CLAVE PARA MANDO) ---
func _input(event):
	# 1. SOLTAR (Mouse o Mando)
	if is_dragging:
		if event.is_action_released("click_mando") or (event is InputEventMouseButton and not event.pressed):
			is_spraying = false 
			is_dragging = false
			regresar_suavemente() 
			return
	
	# 2. AGARRAR CON MANDO (Botón X)
	if mouse_sobre_mi and Input.is_action_just_pressed("click_mando"):
		iniciar_arrastre()

# --- INPUT ORIGINAL DE MOUSE ---
func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		iniciar_arrastre()

# --- FUNCIÓN COMÚN DE ARRASTRE ---
func iniciar_arrastre():
	if tween and tween.is_running(): tween.kill()
	is_dragging = true
	drag_offset = global_position - get_global_mouse_position()
	
	# Vibración al agarrar
	if OS.has_feature("mobile"): Input.vibrate_handheld(50)

# --- PROCESO ---
func _process(delta):
	if is_dragging:
		global_position = get_global_mouse_position() + drag_offset

	# Lógica de Spray
	if is_spraying:
		var asteroide_node = get_tree().root.get_node("Cepillar/Asteroide") 
		if asteroide_node:
			asteroide_node.recibir_enjuague(delta)
			
		# FEEDBACK HÁPTICO (Spray suave)
		if OS.has_feature("mobile"):
			Input.vibrate_handheld(15)

func regresar_suavemente():
	tween = create_tween()
	tween.tween_property(self, "global_position", posicion_inicial, 0.3)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)

func _on_area_entered(area: Area2D) -> void:
	if area.name == "AreaEnjuague": 
		is_spraying = true

func _on_area_exited(area: Area2D) -> void:
	if area.name == "AreaEnjuague":
		is_spraying = false
