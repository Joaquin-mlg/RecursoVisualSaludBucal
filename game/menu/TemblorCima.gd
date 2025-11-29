extends Node2D  # Cambia a Node2D si lo usas en un Sprite, usa Control para botones/texturas de menú

@export_category("Movimiento Vertical")
@export var altura_flote: float = 15.0  # Qué tanto sube
@export var velocidad: float = 3.0      # Qué tan rápido hace el ciclo

@export_category("Vibración en la Cima")
@export var fuerza_vibracion: float = 4.0 # Qué tan fuerte tiembla
@export var zona_activacion: float = 0.7  # 0.0 a 1.0. (0.7 significa: vibrar en el 30% superior del recorrido)

var tiempo: float = 0.0
var y_inicial: float = 0.0
var x_inicial: float = 0.0

func _ready():
	y_inicial = position.y
	x_inicial = position.x # Guardamos X para que la vibración no lo mueva de lugar permanentemente

func _process(delta):
	tiempo += delta
	
	# Calculamos la onda (-1 a 1)
	# Multiplicamos por -1 para que el inicio del ciclo sea hacia ARRIBA (en Godot -Y es arriba)
	var onda = sin(tiempo * velocidad) * -1
	
	# 1. Movimiento base en Y
	var nuevo_y = y_inicial + (onda * altura_flote)
	var nuevo_x = x_inicial
	
	# 2. Lógica de Vibración
	# Si la onda es mayor que el umbral (ej. > 0.7), significa que está llegando arriba
	if onda > zona_activacion:
		# Añadimos un offset aleatorio (temblor) en X e Y
		nuevo_x += randf_range(-fuerza_vibracion, fuerza_vibracion)
		nuevo_y += randf_range(-fuerza_vibracion, fuerza_vibracion)
	
	# Aplicamos la posición final
	position.y = nuevo_y
	position.x = nuevo_x
