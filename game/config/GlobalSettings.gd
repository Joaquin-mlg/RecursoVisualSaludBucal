# GlobalSettings.gd
extends Node

# Señal para avisar a todos los objetos que se actualicen
signal configuracion_cambiada

# Variables de configuración (Valores por defecto)
var tamanio_botones: float = 1.0 # 1.0 es normal, 1.5 es grande
var velocidad_juego: float = 1.0 # 1.0 es normal, 0.5 es cámara lenta
var modo_alto_contraste: bool = false # Para cambiar colores

func actualizar_configuracion(nuevo_tamanio, nueva_velocidad, alto_contraste):
	tamanio_botones = nuevo_tamanio
	velocidad_juego = nueva_velocidad
	modo_alto_contraste = alto_contraste
	
	# 1. Aplicar velocidad inmediatamente (esto afecta a todo el motor)
	Engine.time_scale = velocidad_juego
	
	# 2. Avisar a la interfaz que se redibuje
	emit_signal("configuracion_cambiada")
