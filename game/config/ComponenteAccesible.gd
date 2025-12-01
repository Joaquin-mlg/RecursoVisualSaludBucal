class_name AccesibilidadUI extends Control

func _ready():
	# Configurar el pivote en el centro para que crezca bonito
	# Esto asume que el nodo tiene un tamaño definido.
	pivot_offset = size / 2
	
	GlobalSettings.configuracion_cambiada.connect(aplicar_cambios)
	aplicar_cambios()

func aplicar_cambios():
	# 1. Ajustar Escala usando el valor TRADUCIDO (ej. 1.2)
	var escala = GlobalSettings.tamanio_actual
	scale = Vector2(escala, escala)
	
	# 2. Ajustar Colores
	if GlobalSettings.alto_contraste_activo:
		# Modo Alto Contraste (Amarillo sobre Negro es estándar accesibilidad)
		modulate = Color(1.5, 1.5, 0, 1) 
	else:
		modulate = Color(1, 1, 1, 1)
