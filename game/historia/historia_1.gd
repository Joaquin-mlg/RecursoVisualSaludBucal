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
var input_habilitado = false # Para que no cambien de foto mientras está todo negro

func _ready():
	# 1. Configuración Inicial
	sprite.texture = imagenes[indice]
	telon_negro.color = Color.BLACK
	telon_negro.visible = true
	telon_negro.modulate.a = 1.0 # Opacidad al máximo (Negro total)
	
	# 2. Iniciar la Narración ("Este es el cuarto de Luna...")
	if audio_narrador.stream:
		audio_narrador.play()
	
	# 3. Esperar el tiempo de la introducción a oscuras
	# Cambia 5.0 por los segundos exactos que dura la parte descriptiva del audio
	await get_tree().create_timer(5.0).timeout
	
	# 4. Efecto "Fade In" (El negro se vuelve transparente)
	var tween = create_tween()
	# Esto cambia la transparencia (alpha) a 0 en 2 segundos
	tween.tween_property(telon_negro, "modulate:a", 0.0, 2.0)
	
	# Esperar a que termine la animación para dejar al usuario interactuar
	await tween.finished
	input_habilitado = true

# Lógica unificada para avanzar
func avanzar_historia():
	# Si aún estamos en la intro negra, ignoramos los clics
	if not input_habilitado:
		return

	indice += 1
	if indice < imagenes.size():
		sprite.texture = imagenes[indice]
		# Opcional: Vibrar al cambiar de imagen para feedback táctil
		if OS.has_feature("mobile"):
			Input.vibrate_handheld(50)
	else:
		# Cambiar al minijuego
		get_tree().change_scene_to_file("res://game/minijuegos/esquivar/Esquivar.tscn")

# Input Táctil en cualquier parte de la pantalla
func _unhandled_input(event):
	if (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed):
		avanzar_historia()

# Input si usas un botón específico (TouchScreenButton)
func _on_next_pressed():
	avanzar_historia()
