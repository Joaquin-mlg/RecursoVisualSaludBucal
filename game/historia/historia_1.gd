extends Node2D

# Referencias
# @onready var sprite = $Sprite2D  <-- YA NO SE USA
@onready var video_player = $VideoStreamPlayer # Asegúrate de que el nodo se llame así
@onready var audio_narrador = $AudioStreamPlayer2D

# Variable para evitar saltos dobles
var historia_terminada = false

func _ready():
	print("--- INICIANDO VIDEO HISTORIA ---")
	
	
	# Conectar la señal de cuando el video termina
	# Esto llama a la función terminar_historia automáticamente al final del video
	video_player.finished.connect(terminar_historia)
	
	# Si el video tiene su propio audio, quizás quieras detener el audio_narrador separado
	# Si el video es mudo y usas el audio aparte:
	if audio_narrador.stream:
		audio_narrador.play()
	
	# Comenzar el video (puedes cargarlo aquí o en el inspector)
	# video_player.stream = load("res://ruta/a/tu_video.ogv") 
	video_player.play()

func terminar_historia():
	if historia_terminada:
		return
		
	historia_terminada = true
	print("Fin de historia, cambiando escena...")
	
	# Opcional: Vibrar al terminar si es un salto manual
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(50)
		
	Transicion.cambiar_escena("res://game/minijuegos/esquivar/Esquivar.tscn")

func _input(event):
	# Permitir saltar el video (Skip)
	if historia_terminada:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Jugador saltó el video.")
			terminar_historia()
			
	elif event is InputEventScreenTouch:
		if event.pressed:
			print("Jugador saltó el video.")
			terminar_historia()
