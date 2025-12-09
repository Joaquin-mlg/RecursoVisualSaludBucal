extends CharacterBody2D

# Velocidad BASE. Esta se multiplicará por la configuración global.
@export var velocidad_base := 400.0 

# Variable para el touch
var target_direction: float = 0.0 
# Guardamos el tamaño del jugador para los cálculos de borde
var mitad_ancho_jugador: float = 0.0

func _ready():
	add_to_group("player")
	
	# --- 1. APARECER EN LA MITAD DE LA PANTALLA ---
	var tamanio_pantalla = get_viewport_rect().size
	
	# Centrar en X (Ancho / 2)
	position.x = tamanio_pantalla.x / 2
	
	# Fijar altura en Y (Opcional: Para que aparezca abajo y no arriba a la izquierda)
	# Le restamos 150 pixeles desde el fondo para que no quede pegado al piso
	position.y = tamanio_pantalla.y - 150 
	
	# --- 2. CALCULAR TAMAÑO DEL JUGADOR UNA SOLA VEZ ---
	# Hacemos esto aquí para no recalcularlo en cada frame (optimización)
	if $CollisionShape2D:
		var shape = $CollisionShape2D.shape
		if shape is CircleShape2D:
			mitad_ancho_jugador = shape.radius
		elif shape is RectangleShape2D:
			mitad_ancho_jugador = shape.size.x / 2.0
		else:
			# Valor por defecto si no hay forma (40 pixeles aprox)
			mitad_ancho_jugador = 40.0

func _input(event):
	if event is InputEventScreenTouch:
		var screen_width = get_viewport_rect().size.x
		if event.is_pressed():
			# Lógica simple: Izquierda o Derecha según donde toques
			if event.position.x < screen_width / 2:
				target_direction = -1.0
			else:
				target_direction = 1.0
		else:
			target_direction = 0.0

func _physics_process(delta):
	# --- 1. VELOCIDAD ---
	# Multiplicamos la velocidad base por la configuración
	var velocidad_real = velocidad_base * GlobalSettings.velocidad_actual
	
	# --- 2. DETECTAR INPUT (Fusión de Touch, Teclado y PS4) ---
	var direccion_x: float = 0.0
	
	if target_direction != 0.0:
		# PRIORIDAD 1: Si estás tocando la pantalla (Touch)
		direccion_x = target_direction
	else:
		# PRIORIDAD 2: Mando PS4 o Teclado
		# "get_vector" es mejor que "get_axis" para mandos porque maneja mejor
		# la zona muerta del stick.
		var vector_input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		
		# Solo nos interesa el movimiento horizontal (.x)
		direccion_x = vector_input.x
	
	# --- 3. APLICAR MOVIMIENTO ---
	velocity.x = direccion_x * velocidad_real
	velocity.y = 0 # Mantenemos Y en 0 para que no se mueva arriba/abajo
	
	move_and_slide()
	
	# --- 4. RESTRICCION DE BORDES (CLAMP) ---
	var ancho_pantalla = get_viewport_rect().size.x
	
	position.x = clamp(
		position.x, 
		mitad_ancho_jugador, 
		ancho_pantalla - mitad_ancho_jugador
	)
