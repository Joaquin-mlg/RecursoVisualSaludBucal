extends Node2D # O Node2D, funciona para ambos si heredas de CanvasItem

@export_category("Configuración de Flote (Movimiento)")
@export var flotar_activo: bool = true
@export var distancia_flote: float = 10.0 # Qué tanto sube y baja
@export var velocidad_flote: float = 2.0  # Qué tan rápido lo hace

@export_category("Configuración de Respiración (Escala)")
@export var respirar_activo: bool = false
@export var intensidad_respiracion: float = 0.05 # 0.05 es un 5% de cambio de tamaño
@export var velocidad_respiracion: float = 3.0

@export_category("Configuración de Balanceo (Rotación)")
@export var balanceo_activo: bool = true
@export var angulo_balanceo: float = 3.0 # Grados de rotación
@export var velocidad_balanceo: float = 1.5

@export_category("Variación")
@export var aleatorizar_inicio: bool = true # Importante para que no se muevan todos igual

var tiempo: float = 0.0
var pos_inicial: Vector2
var escala_inicial: Vector2
var rotacion_inicial: float

func _ready():
	# Guardamos cómo estaba el objeto al principio
	pos_inicial = position
	escala_inicial = scale
	rotacion_inicial = rotation_degrees
	
	# Iniciamos en un punto aleatorio del tiempo para que no parezcan soldados marchando
	if aleatorizar_inicio:
		tiempo = randf_range(0.0, 100.0)

func _process(delta):
	tiempo += delta
	
	# 1. Lógica de FLOTAR (Arriba/Abajo)
	if flotar_activo:
		var nuevo_y = pos_inicial.y + (sin(tiempo * velocidad_flote) * distancia_flote)
		position.y = nuevo_y
		
	# 2. Lógica de RESPIRAR (Hacerse grande/pequeño)
	if respirar_activo:
		# IMPORTANTE: Asegúrate que el Pivot Offset del objeto esté en el centro
		var factor = 1.0 + (sin(tiempo * velocidad_respiracion) * intensidad_respiracion)
		scale = escala_inicial * factor

	# 3. Lógica de BALANCEO (Rotar izquierda/derecha)
	if balanceo_activo:
		var nueva_rot = rotacion_inicial + (sin(tiempo * velocidad_balanceo) * angulo_balanceo)
		rotation_degrees = nueva_rot
