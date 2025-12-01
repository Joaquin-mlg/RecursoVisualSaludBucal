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
	# --- 3. INTEGRACIÓN CON GLOBAL SETTINGS ---
	# Multiplicamos la velocidad base por la velocidad actual de la configuración (0.5, 0.8, 1.0)
	var velocidad_real = velocidad_base * GlobalSettings.velocidad_actual
	
	var direccion_final: float = 0.0
	
	# Prioridad al Touch, sino Teclado
	if target_direction != 0.0:
		direccion_final = target_direction
	else:
		direccion_final = Input.get_axis("ui_left", "ui_right")
	
	# Moverse
	velocity.x = direccion_final * velocidad_real
	velocity.y = 0 
	
	move_and_slide()
	
	# --- 4. RESTRICCION DE BORDES (CLAMP) ---
	var ancho_pantalla = get_viewport_rect().size.x
	
	# Clamp asegura que position.x nunca sea menor al mínimo ni mayor al máximo
	# Minimo: 0 + mitad del jugador (para que no se corte el sprite)
	# Maximo: Ancho pantalla - mitad del jugador
	position.x = clamp(
		position.x, 
		mitad_ancho_jugador, 
		ancho_pantalla - mitad_ancho_jugador
	)
