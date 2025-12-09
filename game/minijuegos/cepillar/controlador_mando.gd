extends Node

# Velocidad a la que se mueve el cursor con el joystick
@export var velocidad_cursor: float = 800.0

func _process(delta):
	# 1. MOVER EL CURSOR CON EL STICK
	# Obtenemos hacia donde empuja el joystick
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Si estamos moviendo el stick...
	if input_dir != Vector2.ZERO:
		# Calculamos la nueva posición
		var mouse_pos = get_viewport().get_mouse_position()
		var nueva_pos = mouse_pos + (input_dir * velocidad_cursor * delta)
		
		# Forzamos al mouse a ir a esa posición (¡Magia!)
		get_viewport().warp_mouse(nueva_pos)

	# 2. SIMULAR CLIC CON EL BOTÓN 'X' (Acción: click_mando)
	if Input.is_action_just_pressed("click_mando"):
		_simular_mouse_event(true) # Presionar
		
	if Input.is_action_just_released("click_mando"):
		_simular_mouse_event(false) # Soltar

# Función auxiliar técnica para engañar a Godot
func _simular_mouse_event(presionado: bool):
	var ev = InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = presionado
	ev.position = get_viewport().get_mouse_position()
	ev.global_position = get_viewport().get_mouse_position()
	Input.parse_input_event(ev)
