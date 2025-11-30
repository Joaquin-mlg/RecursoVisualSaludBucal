class_name AccesibilidadUI extends Control
# Al poner class_name, puedes buscar este nodo en el buscador de nodos

func _ready():
	# Conectarse a la señal del cerebro global
	GlobalSettings.configuracion_cambiada.connect(aplicar_cambios)
	# Aplicar cambios apenas nace el objeto
	aplicar_cambios()

func aplicar_cambios():
	# 1. Ajustar Escala (Tamaño)
	# Usamos scale en lugar de size para no romper el layout container si es posible
	# Asegúrate de que el Pivot Offset de tus botones esté en el centro
	scale = Vector2(GlobalSettings.tamanio_botones, GlobalSettings.tamanio_botones)
	
	# 2. Ajustar Colores (Alto Contraste)
	if GlobalSettings.modo_alto_contraste:
		modulate = Color(1.5, 1.5, 0, 1) # Amarillo brillante (ejemplo)
	else:
		modulate = Color(1, 1, 1, 1) # Color original
