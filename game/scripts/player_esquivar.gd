extends CharacterBody2D

@export var velocidad : float = 400.0
var objetivo_x : float = 0.0
var ancho_pantalla : float = 0.0

func _ready():
	ancho_pantalla = ProjectSettings.get_setting("display/window/size/width")
	objetivo_x = position.x

func _process(delta):
	var dir = 0
	if Input.is_action_pressed("ui_left"):
		dir -= 1
	if Input.is_action_pressed("ui_right"):
		dir += 1

	# Movimiento con teclado o toque
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		objetivo_x = get_global_mouse_position().x

	var nueva_x = lerp(position.x, objetivo_x, 0.2)
	position.x = clamp(nueva_x + dir * velocidad * delta, 0, ancho_pantalla)
