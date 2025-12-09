extends Area2D

# --- VARIABLES EXISTENTES ---
var is_dragging = false
var drag_offset = Vector2.ZERO
var posicion_inicial: Vector2 
var tween: Tween 

# --- NUEVO PARA MANDO PS4 ---
var mouse_sobre_mi = false

# --- ACCESIBILIDAD ---
@export_group("Accesibilidad")
@export var audio_descripcion: AudioStream # "Soy el hilo dental..."

@onready var nivel_principal = get_tree().get_first_node_in_group("nivel_cepillar")

func _ready():
	posicion_inicial = global_position 
	
	# CONEXIONES HÍBRIDAS
	mouse_entered.connect(_on_mouse_enter)
	mouse_exited.connect(_on_mouse_exit)

# --- DETECCIÓN DE CURSOR ---
func _on_mouse_enter():
	mouse_sobre_mi = true
	_decir_quien_soy()

func _on_mouse_exit():
	mouse_sobre_mi = false

func _decir_quien_soy():
	if not is_dragging and nivel_principal and nivel_principal.has_method("_reproducir_narracion"):
		nivel_principal._reproducir_narracion(audio_descripcion)

# --- INPUT HÍBRIDO (CLAVE PARA MANDO) ---
func _input(event):
	# 1. SOLTAR
	if is_dragging:
		if event.is_action_released("click_mando") or (event is InputEventMouseButton and not event.pressed):
			is_dragging = false
			regresar_suavemente()
			return
	
	# 2. AGARRAR CON MANDO
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
	
	if OS.has_feature("mobile"): Input.vibrate_handheld(50)

# --- PROCESO ---
func _process(_delta):
	# Solo necesitamos moverlo, el hilo no tiene efecto continuo
	if is_dragging:
		global_position = get_global_mouse_position() + drag_offset

func regresar_suavemente():
	tween = create_tween()
	tween.tween_property(self, "global_position", posicion_inicial, 0.3)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)

# --- DETECCIÓN DE IMPACTO (GOLPE A LA ROCA) ---
func _on_area_entered(area):
	print("Toqué algo llamado: " + area.name) 
	
	if area.is_in_group("rocas"):
		print("¡Es una roca! Intentando dañar...")
		if area.has_method("recibir_dano_hilo_dental"):
			area.recibir_dano_hilo_dental()
		
		# --- FEEDBACK HÁPTICO (GOLPE FUERTE) ---
		if OS.has_feature("mobile"):
			Input.vibrate_handheld(100) # Vibración seca de impacto
			
	else:
		print("Pero no está en el grupo 'rocas'")
