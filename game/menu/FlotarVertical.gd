extends Node2D # Funciona tanto para Control (Botones) como para Node2D (Sprites)

@export_category("Configuración de Levitación")
@export var distancia: float = 8.0  # Cuántos píxeles sube y baja
@export var velocidad: float = 2.0  # Qué tan rápido se mueve
@export var desfase_aleatorio: bool = true # Para que no se muevan todos al mismo tiempo

var tiempo: float = 0.0
var y_inicial: float = 0.0

func _ready():
	# Guardamos la altura original para no perderla
	y_inicial = position.y
	
	# Iniciamos en un punto distinto de la onda senoidal si se pide
	if desfase_aleatorio:
		tiempo = randf_range(0.0, 100.0)

func _process(delta):
	tiempo += delta
	
	# Fórmula mágica de la onda Seno (Sinusoidal)
	# Mueve el objeto arriba y abajo suavemente respecto a su posición original
	var nuevo_y = y_inicial + (sin(tiempo * velocidad) * distancia)
	
	position.y = nuevo_y
