extends Area2D

@onready var nodo_suciedad = $Suciedad
var herramienta_sobre_asteroide: bool = false
var herramienta_actual: Area2D = null

func _ready():
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _on_area_entered(area):
	if area.is_in_group("herramientas") and area.siendo_arrastrada:
		herramienta_sobre_asteroide = true
		herramienta_actual = area
		# Reproducir sonido según el tipo de herramienta
		reproducir_sonido_herramienta(area.tipo_herramienta)

func _on_area_exited(area):
	if area == herramienta_actual:
		herramienta_sobre_asteroide = false
		herramienta_actual = null

func reproducir_sonido_herramienta(tipo_herramienta):
	match tipo_herramienta:
		0: # CEPILLO
			# Reproducir sonido de cepillado
			pass
		1: # HILO
			# Reproducir sonido de hilo dental
			pass
		2: # ENJUAGUE
			# Reproducir sonido de enjuague
			pass

func actualizar_suciedad(porcentaje_limpio: float):
	if nodo_suciedad:
		nodo_suciedad.modulate.a = 1.0 - porcentaje_limpio
