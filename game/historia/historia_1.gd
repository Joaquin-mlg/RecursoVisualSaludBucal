extends Node2D

# Referencias
@onready var sprite = $Sprite2D
@onready var telon_negro = $TelonNegro
@onready var audio_narrador = $AudioStreamPlayer2D

var imagenes = [
	preload("res://game/assets/fondos/historia1_1.png"),
	preload("res://game/assets/fondos/historia1_2.png"),
	preload("res://game/assets/fondos/historia1_3.png"),
	preload("res://game/assets/fondos/historia1_4.png")
]
var indice = 0
var input_habilitado = false 

func _ready():
	print("--- INICIANDO HISTORIA ---")
	sprite.texture = imagenes[indice]
	
	# Configurar telón
	telon_negro.color = Color.BLACK
	telon_negro.visible = true
	telon_negro.modulate.a = 1.0
	# IMPORTANTE: Aseguramos por código que el telón no bloquee clicks
	telon_negro.mouse_filter = Control.MOUSE_FILTER_IGNORE 
	
	if audio_narrador.stream:
		audio_narrador.play()
	
	# Espera inicial
	await get_tree().create_timer(5.0).timeout
	
	# Fade In
	var tween = create_tween()
	tween.tween_property(telon_negro, "modulate:a", 0.0, 2.0)
	
	await tween.finished
	input_habilitado = true
	print(">>> INPUT HABILITADO: Ya puedes hacer click <<<")

func avanzar_historia():
	# Depuración: Ver por qué no avanza
	if not input_habilitado:
		print("Click ignorado: Aún está la intro o transición.")
		return

	print("Avanzando historia...") # Si ves esto, el click funcionó
	indice += 1
	
	if indice < imagenes.size():
		sprite.texture = imagenes[indice]
		if OS.has_feature("mobile"):
			Input.vibrate_handheld(50)
	else:
		print("Fin de historia, cambiando escena...")
		get_tree().change_scene_to_file("res://game/minijuegos/esquivar/Esquivar.tscn")

# CAMBIO AQUÍ: Usamos _input en vez de _unhandled_input
func _input(event):
	# Detectar click izquierdo o toque de pantalla
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			avanzar_historia()
			
	elif event is InputEventScreenTouch:
		if event.pressed:
			avanzar_historia()
