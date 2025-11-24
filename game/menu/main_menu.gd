extends Node2D

# Referencias a los nodos que acabas de crear
# Si les pusiste otro nombre en el editor, cámbialo aquí también
@onready var musica_fondo = $MusicaFondo
@onready var sfx_click = $SFXClick

func _ready():
	# Iniciar música de fondo automáticamente
	if musica_fondo and musica_fondo.stream:
		musica_fondo.play()
	
	# Si tenías código de conexión manual, puedes descomentarlo aquí
	# $CanvasLayer/Control/Button.pressed.connect(_on_start_pressed)

# Creamos una función única para iniciar el juego con efectos
# así la puedes reutilizar en cualquier botón
func transicion_al_juego():
	# 1. Reproducir sonido de click
	if sfx_click and sfx_click.stream:
		sfx_click.play()
	
	# 2. Vibración (Solo funciona en Android/Móvil)
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(100) # Vibra 100 milisegundos
		
	# 3. PAUSA IMPRESCINDIBLE:
	# Esperamos 0.4 segundos para que el sonido se escuche.
	# Si cambiamos de escena de inmediato, el audio se corta.
	await get_tree().create_timer(0.4).timeout
	
	# 4. Cambiar de escena
	# OJO: Verifica mayúsculas/minúsculas en "Historia1.tscn" vs "historia1.tscn"
	# En Android es sensible a mayúsculas, debe ser exacto al nombre del archivo.
	get_tree().change_scene_to_file("res://game/historia/Historia1.tscn")

# --- TUS FUNCIONES CONECTADAS A LOS BOTONES ---

func _on_start_pressed():
	transicion_al_juego()

func _on_button_iniciar_pressed() -> void:
	transicion_al_juego()
