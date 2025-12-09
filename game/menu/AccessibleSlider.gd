extends HSlider

func _ready():
	# Conectar a la señal
	GlobalSettings.high_contrast_changed.connect(actualizar_colores)
	# Aplicar al inicio
	actualizar_colores(GlobalSettings.alto_contraste_activo)

func actualizar_colores(activo: bool):
	if activo:
		# --- MODO ALTO CONTRASTE (Generado por código) ---
		
		# 1. Teñimos el control de AMARILLO PURO.
		# Esto hace que la "perilla" (grabber) se vea amarilla automáticamente.
		modulate = Color(1, 1, 0, 1) 
		
		# 2. Creamos el Riel NEGRO (El fondo de la barra)
		var riel_negro = StyleBoxFlat.new()
		riel_negro.bg_color = Color.BLACK
		
		# Hacemos el riel un poquito más grueso para que se vea bien
		riel_negro.expand_margin_top = 4
		riel_negro.expand_margin_bottom = 4
		riel_negro.corner_radius_top_left = 4
		riel_negro.corner_radius_top_right = 4
		riel_negro.corner_radius_bottom_right = 4
		riel_negro.corner_radius_bottom_left = 4
		
		# Aplicamos el fondo negro
		add_theme_stylebox_override("slider", riel_negro)
		
		# (Opcional) Hacemos que la parte rellena también sea negra o amarilla
		# Aquí le ponemos el mismo estilo negro para simplificar visualmente
		add_theme_stylebox_override("grabber_area", riel_negro)
		add_theme_stylebox_override("grabber_area_highlight", riel_negro)

	else:
		# --- MODO NORMAL (Default de Godot) ---
		
		# 1. Quitamos el tinte (volvemos a blanco/original)
		modulate = Color(1, 1, 1, 1)
		
		# 2. Borramos los estilos manuales para que Godot use su tema default
		remove_theme_stylebox_override("slider")
		remove_theme_stylebox_override("grabber_area")
		remove_theme_stylebox_override("grabber_area_highlight")
