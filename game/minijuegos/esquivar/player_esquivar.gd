extends CharacterBody2D # ¡Correcto!

@export var speed := 350.0 # Velocidad adecuada para CharacterBody2D

# Variable de estado para almacenar la dirección de movimiento deseada por toque
# -1.0 = Izquierda, 1.0 = Derecha, 0.0 = Detenido
var target_direction: float = 0.0 

# Función para configurar el jugador (llamada una vez al inicio)
func _ready():
	# **AGREGADO:** Asegura que el jugador esté en el grupo "player"
	add_to_group("player")
	
# Función para manejar entradas táctiles (TOUCH SCREEN)
# Esta función es crucial para la accesibilidad en Android.
func _input(event):
	# Solo procesamos eventos táctiles en la pantalla (para celular)
	if event is InputEventScreenTouch:
		var screen_width = get_viewport_rect().size.x
		
		if event.is_pressed():
			# Toque inicial: Determinar la dirección
			# Si la posición del toque está en la mitad izquierda de la pantalla
			if event.position.x < screen_width / 2:
				# Mover a la izquierda
				target_direction = -1.0
			else:
				# Mover a la derecha
				target_direction = 1.0
		else:
			# El toque ha terminado: Detener el movimiento táctil
			target_direction = 0.0


func _physics_process(delta):
	# 1. Determinar la dirección de movimiento con prioridad:
	var final_direction: float = 0.0
	
	# Prioridad 1: Input táctil (si el usuario está tocando la pantalla)
	if target_direction != 0.0:
		final_direction = target_direction
	else:
		# Prioridad 2: Input de teclado/virtual (para la opción Web/PC si se exporta)
		final_direction = Input.get_axis("ui_left", "ui_right")
	
	
	# 2. Calcular la nueva velocidad horizontal
	velocity.x = final_direction * speed
	
	# 3. La gravedad no se aplica en este minijuego, la velocidad vertical se mantiene en 0
	velocity.y = 0 
	
	# 4. Mueve el cuerpo del personaje con Godot Physics
	move_and_slide()
	
	# 5. Limitar al jugador a los bordes de la pantalla (para que no salga)
	var screen_width = get_viewport_rect().size.x
	var player_extent = 0.0
	
	# Verificación segura del CollisionShape para evitar errores si no existe
	if $CollisionShape2D and $CollisionShape2D.shape:
		# Intentar obtener el tamaño del shape para el clamp correcto
		if $CollisionShape2D.shape is CircleShape2D:
			player_extent = $CollisionShape2D.shape.radius
		elif $CollisionShape2D.shape is RectangleShape2D:
			player_extent = $CollisionShape2D.shape.size.x / 2.0
	
	# Usar player_extent para el límite (0 + extent, width - extent)
	position.x = clamp(position.x, player_extent, screen_width - player_extent)
