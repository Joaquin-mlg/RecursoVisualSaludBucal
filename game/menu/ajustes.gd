extends Control

# Referencias a los Nodos de UI
@onready var slider_tamanio = $OrgVertical/SliderTamBotones
@onready var slider_velocidad = $OrgVertical/SliderVelocidad
@onready var check_contraste = $OrgVertical/ModoAltoContraste
# Necesitamos una referencia al botón que va a cambiar de icono
@onready var boton_accion = $OrgVertical/Volver_Guardar 

# Pre-cargamos las texturas (Asegúrate de poner la ruta correcta de tus imágenes)
# Si usas Godot 4, puedes arrastrar las imágenes aquí o cargarlas en el inspector
var icono_volver = preload("res://game/menu/fondo/boton-Atrás.png")
var icono_guardar = preload("res://game/menu/fondo/Boton Guardar.png")

func _ready():
	# 1. Cargar los valores iniciales
	slider_tamanio.value = GlobalSettings.tamanio_botones
	slider_velocidad.value = GlobalSettings.velocidad_juego
	check_contraste.button_pressed = GlobalSettings.modo_alto_contraste
	
	# 2. Configurar el estado inicial del botón (debería ser "Volver")
	_actualizar_estado_boton()

	# 3. Conectar señales para detectar cambios en tiempo real
	# "value_changed" es para sliders, "toggled" para checkboxes
	slider_tamanio.value_changed.connect(_on_cambio_detectado)
	slider_velocidad.value_changed.connect(_on_cambio_detectado)
	check_contraste.toggled.connect(_on_cambio_detectado)

# Esta función se ejecuta cada vez que mueves algo en la UI
func _on_cambio_detectado(_valor = null):
	_actualizar_estado_boton()

func _actualizar_estado_boton():
	# Verificamos si ALGO es diferente a lo que hay en la configuración global
	var hay_cambios = (
		slider_tamanio.value != GlobalSettings.tamanio_botones or 
		slider_velocidad.value != GlobalSettings.velocidad_juego or
		check_contraste.button_pressed != GlobalSettings.modo_alto_contraste
	)
	
	if hay_cambios:
		# Si hay cambios, ponemos el icono de GUARDAR
		boton_accion.icon = icono_guardar
		# Opcional: Cambiar el texto si el botón tiene texto
		# boton_accion.text = "GUARDAR" 
	else:
		# Si es igual al guardado, ponemos el icono de VOLVER
		boton_accion.icon = icono_volver
		# boton_accion.text = "VOLVER"
func _on_volver_guardar_pressed():
	# Verificamos de nuevo si hay cambios para saber qué lógica aplicar
	var hay_cambios = (
		slider_tamanio.value != GlobalSettings.tamanio_botones or 
		slider_velocidad.value != GlobalSettings.velocidad_juego or
		check_contraste.button_pressed != GlobalSettings.modo_alto_contraste
	)
	
	if hay_cambios:
		# LÓGICA DE GUARDAR
		print("Guardando cambios...")
		GlobalSettings.actualizar_configuracion(
			slider_tamanio.value,
			slider_velocidad.value,
			check_contraste.button_pressed
		)
		# Después de guardar, regresamos al menú
		get_tree().change_scene_to_file("res://game/menu/main.tscn")
	else:
		# LÓGICA DE VOLVER (Sin guardar)
		print("Volviendo sin cambios...")
		get_tree().change_scene_to_file("res://game/menu/main.tscn")
