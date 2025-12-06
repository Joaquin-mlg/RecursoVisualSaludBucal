extends Node2D

@onready var parallax_infinite = $ParallaxInfinite
@onready var intro_group = $Intro

# Variable para saber si la intro sigue activa
var intro_jugandose = true

func _ready():
	# Aseguramos que el parallax infinito se repita verticalmente
	# Asumiendo que parallax3.jpg mide 1080px de alto
	parallax_infinite.repeat_size.y = 1380
	
	# Sincronizamos la velocidad inicial
	# Puedes cambiar la velocidad aquí
	parallax_infinite.autoscroll.y = 150 

func _process(delta):
	if intro_jugandose:
		# Obtenemos la velocidad a la que se mueve el espacio
		var velocidad = parallax_infinite.autoscroll.y
		
		# Movemos el grupo de la intro (Ciudad + Transición) hacia ABAJO
		intro_group.position.y += velocidad * delta
		
		# CONDICIÓN DE FIN:
		# Si el grupo bajó más de 2500px, ya salió de la pantalla por abajo.
		# (1080 pantalla + 1080 transición + margen)
