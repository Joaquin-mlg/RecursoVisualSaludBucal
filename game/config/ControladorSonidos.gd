extends Node
class_name ControladorSonidos

# Arrastra aquí tu archivo de sonido (wav/mp3) desde el Inspector
@export var sonido_click: AudioStream

# Creamos el reproductor de audio por código para no ensuciar la escena
var _player: AudioStreamPlayer

func _ready():
	# 1. Configurar el reproductor de audio
	_player = AudioStreamPlayer.new()
	_player.stream = sonido_click
	# Opcional: bajarle un poco el volumen (-5 decibeles)
	_player.volume_db = -5.0 
	add_child(_player)
	
	# 2. Buscar botones en TODA la escena y conectarlos
	_conectar_botones_recursivo(get_parent())

func _conectar_botones_recursivo(nodo: Node):
	# Si el nodo es un botón (Normal o de Textura), lo conectamos
	if nodo is Button or nodo is TextureButton:
		# Verificamos si ya está conectado para no repetir
		if not nodo.pressed.is_connected(_reproducir_sonido):
			nodo.pressed.connect(_reproducir_sonido)
	
	# Buscamos dentro de los hijos de este nodo (para encontrar botones dentro de paneles, cajas, etc.)
	for hijo in nodo.get_children():
		_conectar_botones_recursivo(hijo)

func _reproducir_sonido():
	# Truco: Variamos un poquito el tono (pitch) para que no suene robótico
	_player.pitch_scale = randf_range(0.95, 1.05)
	_player.play()
