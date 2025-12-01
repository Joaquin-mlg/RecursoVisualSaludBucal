class_name EfectoIdle extends Node

# --- CONFIGURACIÓN ---
enum TipoAnimacion {
	FLOTAR_VERTICAL,
	FLOTAR_HORIZONTAL,
	LATIDO_ESCALA,
	PENDULO_ROTACION,
	TEMBLOR
}

@export var tipo: TipoAnimacion = TipoAnimacion.FLOTAR_VERTICAL
@export var velocidad: float = 2.0
@export var amplitud: float = 10.0
@export var aleatorio: bool = true 

# --- VARIABLES INTERNAS ---
var tiempo: float = 0.0

# CORRECCIÓN: Cambiamos ": Node2D" por ": Node" para que acepte Controls también
var padre: Node 

var valor_inicial_pos: Vector2
var valor_inicial_rot: float
var valor_inicial_esc: Vector2

func _ready():
	padre = get_parent()
	
	# Ahora esta comprobación funcionará perfectamente
	if not (padre is Node2D or padre is Control):
		set_physics_process(false)
		print("Error: EfectoIdle debe ser hijo de un Node2D o Control")
		return
	
	valor_inicial_pos = padre.position
	valor_inicial_rot = padre.rotation_degrees
	valor_inicial_esc = padre.scale
	
	if aleatorio:
		tiempo = randf_range(0.0, 10.0)

func _physics_process(delta):
	tiempo += delta * velocidad
	var onda = sin(tiempo) 
	
	match tipo:
		TipoAnimacion.FLOTAR_VERTICAL:
			padre.position.y = valor_inicial_pos.y + (onda * amplitud)
			
		TipoAnimacion.FLOTAR_HORIZONTAL:
			padre.position.x = valor_inicial_pos.x + (onda * amplitud)
			
		TipoAnimacion.LATIDO_ESCALA:
			var escala_nueva = 1.0 + (onda * (amplitud * 0.01)) 
			padre.scale = valor_inicial_esc * escala_nueva
			
		TipoAnimacion.PENDULO_ROTACION:
			padre.rotation_degrees = valor_inicial_rot + (onda * amplitud)
			
		TipoAnimacion.TEMBLOR:
			var ruido_x = randf_range(-1, 1) * amplitud
			var ruido_y = randf_range(-1, 1) * amplitud
			padre.position = valor_inicial_pos + Vector2(ruido_x, ruido_y)
