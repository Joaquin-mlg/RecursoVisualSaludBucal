extends Control

signal carta_seleccionada(carta)

var id_pareja: String 
var textura_frente: Texture2D
var textura_reverso: Texture2D

var esta_volteada: bool = false
var esta_bloqueada: bool = false

@onready var boton = $Boton

func _ready():
	# Asegura que el pivote esté en el centro para la animación
	pivot_offset = size / 2
	boton.pressed.connect(_on_button_pressed)

func configurar_carta(tex_frente: Texture2D, tex_reverso: Texture2D, id: String):
	textura_frente = tex_frente
	textura_reverso = tex_reverso
	id_pareja = id
	boton.texture_normal = textura_reverso

func _on_button_pressed():
	if esta_bloqueada or esta_volteada:
		return
	carta_seleccionada.emit(self)

func voltear():
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# 1. Contrae la carta hasta que desaparece (efecto de borde)
	tween.tween_property(self, "scale:x", 0.0, 0.15)
	tween.tween_callback(_cambiar_textura)
	# 2. Expande la carta de nuevo
	tween.tween_property(self, "scale:x", 1.0, 0.15)

func _cambiar_textura():
	esta_volteada = !esta_volteada
	if esta_volteada:
		boton.texture_normal = textura_frente
	else:
		boton.texture_normal = textura_reverso

func emparejar_exito():
	esta_bloqueada = true
	# Opcional: Bajar opacidad para indicar que ya está lista
	modulate.a = 0.6 

func reiniciar():
	esta_volteada = false
	esta_bloqueada = false
	boton.texture_normal = textura_reverso
	modulate.a = 1.0
