extends Control

# Referencias a los Nodos de UI
@onready var slider_tamanio = $OrgVertical/SliderTamBotones
@onready var slider_velocidad = $OrgVertical/SliderVelocidad
@onready var check_contraste = $OrgVertical/ModoAltoContraste
@onready var boton_accion = $Volver_Guardar 

# --- NUEVO: CARGAMOS LAS 4 IMÁGENES NECESARIAS ---
@export_group("Iconos Boton Acción")
@export var volver_normal: Texture2D  # Arrastra el "Atrás" normal
@export var volver_ac: Texture2D      # Arrastra el "Atrás" amarillo/negro
@export var guardar_normal: Texture2D # Arrastra el "Guardar" normal
@export var guardar_ac: Texture2D     # Arrastra el "Guardar" amarillo/negro

var hay_cambios = false

func _ready():
	# 1. Cargar valores iniciales
	slider_tamanio.value = GlobalSettings.indice_tamanio_guardado
	slider_velocidad.value = GlobalSettings.indice_velocidad_guardado
	check_contraste.button_pressed = GlobalSettings.alto_contraste_activo
	
	# 2. Conectar señales
	slider_tamanio.value_changed.connect(_on_cambio_detectado.unbind(1))
	slider_velocidad.value_changed.connect(_on_cambio_detectado.unbind(1))
	check_contraste.toggled.connect(_on_cambio_detectado.unbind(1))
	
	boton_accion.pressed.connect(_on_volver_guardar_pressed)
	
	# 3. Actualizar botón INMEDIATAMENTE al entrar
	# Esto arregla tu problema: verificará si el AC está activo desde el inicio
	_actualizar_estado_boton()

func _on_cambio_detectado():
	# Preview visual inmediato del contraste
	GlobalSettings.set_high_contrast(check_contraste.button_pressed)
	_actualizar_estado_boton()

func _actualizar_estado_boton():
	# Detectar si hay cambios pendientes
	hay_cambios = (
		slider_tamanio.value != GlobalSettings.indice_tamanio_guardado or 
		slider_velocidad.value != GlobalSettings.indice_velocidad_guardado or
		check_contraste.button_pressed != GlobalSettings.alto_contraste_activo
	)
	
	# Detectar qué modo visual estamos viendo AHORA MISMO
	# Usamos el estado del checkbox porque es lo que el usuario está viendo en pantalla
	var usar_ac = check_contraste.button_pressed
	
	if hay_cambios:
		# Lógica para mostrar icono de GUARDAR
		if usar_ac and guardar_ac:
			boton_accion.icon = guardar_ac
		else:
			boton_accion.icon = guardar_normal
	else:
		# Lógica para mostrar icono de VOLVER
		if usar_ac and volver_ac:
			boton_accion.icon = volver_ac
		else:
			boton_accion.icon = volver_normal

func _on_volver_guardar_pressed():
	if hay_cambios:
		print("Guardando cambios...")
		GlobalSettings.actualizar_configuracion(
			int(slider_tamanio.value),
			int(slider_velocidad.value),
			check_contraste.button_pressed
		)
		Transicion.cambiar_escena("res://game/menu/main.tscn")
	else:
		print("Volviendo sin cambios...")
		# Revertir visualmente si cancelamos cambios de contraste
		GlobalSettings.set_high_contrast(GlobalSettings.alto_contraste_activo)
		Transicion.cambiar_escena("res://game/menu/main.tscn")
