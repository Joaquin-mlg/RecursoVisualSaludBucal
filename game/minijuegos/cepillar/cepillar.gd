extends Node2D

var progreso_limpieza: float = 0.0
var progreso_maximo: float = 100.0

@onready var asteroide = $Asteroide
@onready var barra_progreso = $UI/ProgresoLimpieza
@onready var texto_instrucciones = $UI/TextoInstrucciones

func _ready():
	barra_progreso.max_value = progreso_maximo
	barra_progreso.value = 0
	texto_instrucciones.text = "Toca y mantén presionado una herramienta para usarla"

func _process(delta):
	# Verificar si alguna herramienta está sobre el asteroide
	if asteroide.herramienta_sobre_asteroide:
		aumentar_limpieza(0.8 * delta)  # Limpieza continua mientras está sobre el asteroide

func aumentar_limpieza(cantidad: float):
	progreso_limpieza += cantidad
	barra_progreso.value = progreso_limpieza
	
	# Actualizar visual de suciedad
	if asteroide.has_method("actualizar_suciedad"):
		asteroide.actualizar_suciedad(progreso_limpieza / progreso_maximo)
	
	if progreso_limpieza >= progreso_maximo:
		completar_juego()

func completar_juego():
	texto_instrucciones.text = "¡Asteroide limpio! ¡Perfecto!"
	# Desactivar todas las herramientas
	for herramienta in $Herramientas.get_children():
		herramienta.set_process_input(false)
	
	await get_tree().create_timer(2.0).timeout
	# Ir a siguiente escena
	print("Minijuego completado!")
