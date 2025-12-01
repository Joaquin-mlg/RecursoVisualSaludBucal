extends Sprite2D

# Configuración
@export var intensidad_movimiento : float = 30.0 # Cuántos píxeles se mueve máximo
@export var velocidad_suavizado : float = 5.0    # Qué tan suave sigue el movimiento (Lerp)

var posicion_inicial : Vector2

func _ready():
	# Guardamos la posición original (el centro) para volver siempre ahí
	posicion_inicial = position

func _process(delta):
	var offset_objetivo = Vector2.ZERO
	
	# DETECCIÓN: ¿Estamos usando acelerómetro (Móvil)?
	var acelerometro = Input.get_accelerometer()
	
	# En Godot, si no hay sensor, el vector suele ser (0,0,0) o muy cercano
	# Usamos una magnitud mayor a 0 para saber si hay datos del sensor
	if acelerometro.length() > 0:
		# En Android, el eje X es izquierda/derecha.
		# Multiplicamos por -1 para invertir el movimiento (efecto profundidad)
		offset_objetivo.x = acelerometro.x * -intensidad_movimiento
		offset_objetivo.y = acelerometro.y * intensidad_movimiento
	
	else:
		# DETECCIÓN: Si no hay sensor, usamos el Ratón (PC)
		var mouse_pos = get_viewport().get_mouse_position()
		var tamaño_pantalla = get_viewport_rect().size
		var centro = tamaño_pantalla / 2
		
		# Calculamos distancia del ratón al centro (-1 a 1 aprox)
		var direccion = (mouse_pos - centro) / centro
		
		# Movemos el fondo en dirección contraria al ratón para dar profundidad
		offset_objetivo = direccion * -intensidad_movimiento

	# APLICAR MOVIMIENTO
	# Usamos 'lerp' (interpolación lineal) para que el movimiento sea suave y no brusco
	var nueva_posicion = posicion_inicial + offset_objetivo
	position = position.lerp(nueva_posicion, velocidad_suavizado * delta)
