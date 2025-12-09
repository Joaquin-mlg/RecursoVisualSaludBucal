extends CheckBox

# --- IMÁGENES NORMALES (Para que no se pierdan) ---
@export_group("Iconos Normales")
@export var normal_checked: Texture2D   # Arrastra aquí tu icono normal con visto
@export var normal_unchecked: Texture2D # Arrastra aquí tu icono normal vacío

# --- IMÁGENES ALTO CONTRASTE ---
@export_group("Iconos Alto Contraste")
@export var ac_checked: Texture2D       # Arrastra aquí el icono amarillo con visto
@export var ac_unchecked: Texture2D     # Arrastra aquí el icono amarillo vacío

func _ready():
	# 1. Aseguramos que el checkbox marque lo correcto según la memoria	
	# 2. Nos conectamos para escuchar cambios
	GlobalSettings.high_contrast_changed.connect(actualizar_visuales)
	
	# 3. Aplicamos los iconos correspondientes al iniciar
	actualizar_visuales(GlobalSettings.alto_contraste_activo)

func actualizar_visuales(activo: bool):
	if activo:
		# --- MODO ALTO CONTRASTE ---
		if ac_checked:
			add_theme_icon_override("checked", ac_checked)
		if ac_unchecked:
			add_theme_icon_override("unchecked", ac_unchecked)
	else:
		# --- MODO NORMAL (Restauramos tus imagenes originales) ---
		# En lugar de "remove", las volvemos a poner explícitamente
		if normal_checked:
			add_theme_icon_override("checked", normal_checked)
		if normal_unchecked:
			add_theme_icon_override("unchecked", normal_unchecked)
