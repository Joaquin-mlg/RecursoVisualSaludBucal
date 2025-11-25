extends Node2D

# Referencias
@onready var sprite = $Sprite2D
@onready var telon_negro = $TelonNegro # El ColorRect que acabamos de crear
@onready var audio_narrador = $AudioStreamPlayer2D # Tu nodo de audio

# Tus imágenes
var imagenes = [
	preload("res://game/assets/fondos/historia1_1.png"),
	preload("res://game/assets/fondos/historia1_2.png"),
	preload("res://game/assets/fondos/historia1_3.png"),
	preload("res://game/assets/fondos/historia1_4.png")
]
var indice = 0
var input_habilitado = false # Para que no cambien de foto mientras está en transición

#-------------------------------------------------------------------------------
# 1. Configuración Inicial y Primer Fundido (Fade In)
#-------------------------------------------------------------------------------
func _ready():
	# 1. Configuración Inicial
	sprite.texture = imagenes[indice]
	# Aseguramos que el Telón Negro esté visible y en opacidad total al inicio
	telon_negro.color = Color.BLACK
	telon_negro.visible = true
	telon_negro.modulate.a = 1.0 # Opacidad al máximo (Negro total)
	
	# 2. Iniciar la Narración
	if audio_narrador.stream:
		audio_narrador.play()
	
	# 3. Esperar el tiempo de la introducción a oscuras (Ej. 2 segundos)
	# Ajusta el tiempo según la duración de la primera parte del audio.
	await get_tree().create_timer(2.0).timeout
	
	# 4. Efecto "Fade In" (El negro se vuelve transparente)
	var tween = create_tween()
	# Esto cambia la transparencia (alpha) a 0 en 2 segundos
	tween.tween_property(telon_negro, "modulate:a", 0.0, 2.0)
	
	# Esperar a que termine la animación para dejar al usuario interactuar
	await tween.finished
	telon_negro.visible = false # Ocultar el telón al final del primer fundido
	input_habilitado = true


#-------------------------------------------------------------------------------
# 2. Lógica para Avanzar con Transición (Fade Out / Fade In)
#-------------------------------------------------------------------------------
func avanzar_historia():
	# Si aún estamos en la intro negra o en una transición, ignoramos los clics
	if not input_habilitado:
		return
	
	# Deshabilitamos el input mientras la transición ocurre
	input_habilitado = false 
	
	indice += 1
	
	if indice < imagenes.size():
		
		# --- INICIO DE LA TRANSICIÓN: FADE OUT (Fundido a Negro) ---
		var tween_out = create_tween()
		telon_negro.visible = true # Aseguramos que el telón esté visible
		# Fundir a negro (opacidad del telón a 1.0) en 0.5 segundos
		tween_out.tween_property(telon_negro, "modulate:a", 1.0, 0.5) 
		
		await tween_out.finished
		# Ya está totalmente negro: momento seguro para cambiar la imagen
		
		# CAMBIO DE IMAGEN
		sprite.texture = imagenes[indice]
		
		# Opcional: Vibrar para feedback
		if OS.has_feature("mobile"):
			Input.vibrate_handheld(50)
		
		# --- FIN DE LA TRANSICIÓN: FADE IN (Fundido de Entrada) ---
		var tween_in = create_tween()
		# Fundir de entrada (opacidad del telón a 0.0) en 0.5 segundos
		tween_in.tween_property(telon_negro, "modulate:a", 0.0, 0.5)
		
		await tween_in.finished
		telon_negro.visible = false # Ocultar el telón
		
		# Habilitar input de nuevo
		input_habilitado = true
	
	else:
		# Cambiar al minijuego
		get_tree().change_scene_to_file("res://game/minijuegos/esquivar/Esquivar.tscn")

#-------------------------------------------------------------------------------
# 3. Manejo de Input
#-------------------------------------------------------------------------------
# Input Táctil/Ratón en cualquier parte de la pantalla
func _unhandled_input(event):
	if (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed):
		avanzar_historia()

# Input si usas un botón específico (TouchScreenButton)
func _on_next_pressed():
	avanzar_historia()
