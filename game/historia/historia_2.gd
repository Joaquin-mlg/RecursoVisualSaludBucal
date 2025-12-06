extends Node2D

# Referencias
# @onready var sprite = $Sprite2D <-- YA NO SE USA
@onready var video_player = $VideoStreamPlayer # Recuerda agregar este nodo en la escena Historia 2
# @onready var audio_narrador = $AudioStreamPlayer2D # Descomenta si tienes audio aparte del video

# Variable para evitar saltos dobles
var historia_terminada = false

func _ready():
	print("--- INICIANDO VIDEO HISTORIA 2 ---")
	
	# Configurar telón inicial (si copiaste el nodo TelonNegro a esta escena)
	
	# Conectar la señal de cuando el video termina
	video_player.finished.connect(terminar_historia)
	
	# Iniciar video
	video_player.play()
	

func terminar_historia():
	if historia_terminada:
		return
		
	historia_terminada = true
	print("Fin de historia 2, cambiando a Cepillar...")
	
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(50)
		
	# Usamos Transicion como en tu código "bueno", apuntando a Cepillar
	# Si en esta escena no tienes el autoload Transicion, usa get_tree().change_scene_to_file(...)
	Transicion.cambiar_escena("res://game/minijuegos/cepillar/Cepillar.tscn")

func _input(event):
	# Permitir saltar el video (Skip)
	if historia_terminada:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			terminar_historia()
			
	elif event is InputEventScreenTouch:
		if event.pressed:
			terminar_historia()

# Esta función ya no es necesaria si usas el toque en pantalla completo, 
# pero si tienes un botón específico puedes dejarla conectada:
func _on_next_pressed():
	terminar_historia()
