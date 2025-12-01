extends Control

# Referencias a los Nodos de UI
@onready var slider_tamanio = $OrgVertical/SliderTamBotones
@onready var slider_velocidad = $OrgVertical/SliderVelocidad
@onready var check_contraste = $OrgVertical/ModoAltoContraste
@onready var boton_accion = $Volver_Guardar 

# Pre-cargamos las texturas
var icono_volver = preload("res://game/menu/fondo/boton-Atrás.png")
var icono_guardar = preload("res://game/menu/fondo/Boton Guardar.png")

var hay_cambios = false

func _ready():
	# CORRECCIÓN 1: Usamos las variables de ÍNDICE del GlobalSettings
	slider_tamanio.value = GlobalSettings.indice_tamanio_guardado
	slider_velocidad.value = GlobalSettings.indice_velocidad_guardado
	check_contraste.button_pressed = GlobalSettings.alto_contraste_activo
	
	_actualizar_estado_boton()

	slider_tamanio.value_changed.connect(_on_cambio_detectado)
	slider_velocidad.value_changed.connect(_on_cambio_detectado)
	check_contraste.toggled.connect(_on_cambio_detectado)

func _on_cambio_detectado(_valor = null):
	_actualizar_estado_boton()

func _actualizar_estado_boton():
	# CORRECCIÓN 2: Aquí estaba el error. 
	# Comparamos el valor del slider (1,2,3,4) con el índice guardado (1,2,3,4).
	hay_cambios = (
		slider_tamanio.value != GlobalSettings.indice_tamanio_guardado or 
		slider_velocidad.value != GlobalSettings.indice_velocidad_guardado or
		check_contraste.button_pressed != GlobalSettings.alto_contraste_activo
	)
	
	if hay_cambios:
		boton_accion.icon = icono_guardar
	else:
		boton_accion.icon = icono_volver

func _on_volver_guardar_pressed():
		# CORRECCIÓN 3: Limpié la lógica repetida.
	
	if hay_cambios:
		print("Guardando cambios...")
		# Enviamos los ints (1, 2, 3, 4) al GlobalSettings
		GlobalSettings.actualizar_configuracion(
			int(slider_tamanio.value),
			int(slider_velocidad.value),
			check_contraste.button_pressed
		)
		# Usamos tu transición bonita si quieres, o el cambio normal
		get_tree().change_scene_to_file("res://game/menu/main.tscn")
	else:
		print("Volviendo sin cambios...")
		get_tree().change_scene_to_file("res://game/menu/main.tscn")
