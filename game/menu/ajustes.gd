
extends Control

# Referencias a los Nodos de UI
@onready var slider_tamanio = $OrgVertical/SliderTamBotones
@onready var slider_velocidad = $OrgVertical/SliderVelocidad
@onready var check_contraste = $OrgVertical/ModoAltoContraste
@onready var boton_accion = $Volver_Guardar 

# --- NUEVO: REFERENCIA DE AUDIO ---
@onready var audio_player = $AudioStreamPlayer 

# --- IMÁGENES ALTO CONTRASTE ---
@export_group("Iconos Boton Acción")
@export var volver_normal: Texture2D  
@export var volver_ac: Texture2D      
@export var guardar_normal: Texture2D 
@export var guardar_ac: Texture2D     

# --- AUDIOS NARRATIVOS (NUEVO) ---
@export_group("Audios Accesibilidad")
@export var audio_slider_tam: AudioStream   # "Desliza para cambiar el tamaño de los botones"
@export var audio_slider_vel: AudioStream   # "Desliza para cambiar la velocidad del juego"
@export var audio_check_ac: AudioStream     # "Casilla: Activar modo alto contraste"
@export var audio_btn_volver: AudioStream   # "Botón: Volver al menú"
@export var audio_btn_guardar: AudioStream  # "Botón: Guardar cambios"

var hay_cambios = false

func _ready():
	# 1. Cargar valores iniciales
	slider_tamanio.value = GlobalSettings.indice_tamanio_guardado
	slider_velocidad.value = GlobalSettings.indice_velocidad_guardado
	check_contraste.button_pressed = GlobalSettings.alto_contraste_activo
	
	# 2. Conectar señales de lógica
	slider_tamanio.value_changed.connect(_on_cambio_detectado.unbind(1))
	slider_velocidad.value_changed.connect(_on_cambio_detectado.unbind(1))
	check_contraste.toggled.connect(_on_cambio_detectado.unbind(1))
	
	# 3. Conectar señales de AUDIO (Hover / Dedo)
	# Usamos funciones anónimas para los elementos fijos
	slider_tamanio.mouse_entered.connect(func(): _reproducir_audio(audio_slider_tam))
	slider_velocidad.mouse_entered.connect(func(): _reproducir_audio(audio_slider_vel))
	check_contraste.mouse_entered.connect(func(): _reproducir_audio(audio_check_ac))
	
	# IMPORTANTE: El botón de acción es dinámico, usa una función especial
	boton_accion.mouse_entered.connect(_reproducir_audio_accion_dinamico)
	
	# 4. Actualizar estado inicial visual
	_actualizar_estado_boton()

# --- FUNCIÓN DE AUDIO DINÁMICO ---
func _reproducir_audio_accion_dinamico():
	# Esta función decide qué audio tocar dependiendo si hay cambios o no
	if hay_cambios:
		_reproducir_audio(audio_btn_guardar)
	else:
		_reproducir_audio(audio_btn_volver)

# --- FUNCIÓN GENERICA DE REPRODUCCIÓN ---
func _reproducir_audio(stream: AudioStream):
	if stream == null: return
	
	if audio_player.playing:
		audio_player.stop()
		
	audio_player.stream = stream
	audio_player.play()

# --- LÓGICA VISUAL Y DE GUARDADO (IGUAL QUE ANTES) ---

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
