extends Button

# --- CONFIGURACIÓN VISUAL ---
@export_category("Animación")
@export var escala_crecimiento: Vector2 = Vector2(1.1, 1.1)
@export var tiempo_animacion: float = 0.1

# --- CONFIGURACIÓN DE AUDIO ---
@export_category("Audio")
@export var sfx_click: AudioStream # <--- Arrastra tu archivo de sonido aquí en el Inspector

var escala_original: Vector2
var reproductor_sonido: AudioStreamPlayer # Creamos el reproductor por código para no ensuciar la escena

func _ready():
	# 1. Preparativos Visuales
	escala_original = scale
	pivot_offset = size / 2
	
	# 2. Preparativos de Audio (Creamos el nodo invisiblemente)
	reproductor_sonido = AudioStreamPlayer.new()
	add_child(reproductor_sonido) # Lo agregamos al botón
	if sfx_click:
		reproductor_sonido.stream = sfx_click
	
	# 3. Conexiones
	mouse_entered.connect(_animar_crecer)
	mouse_exited.connect(_animar_volver)
	button_down.connect(_animar_pulsar)
	button_up.connect(_animar_soltar)
	
	pressed.connect(_accion_salir)

# --- ANIMACIONES ---
func _animar_crecer():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", escala_crecimiento, tiempo_animacion)

func _animar_volver():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", escala_original, tiempo_animacion)

func _animar_pulsar():
	var tween = create_tween()
	tween.tween_property(self, "scale", escala_original * 0.95, 0.05)

func _animar_soltar():
	_animar_crecer()

# --- LÓGICA DE SALIR ---
func _accion_salir():
	print("Saliendo del juego...")
	
	# 1. Reproducir sonido si existe
	if sfx_click: 
		reproductor_sonido.play()
		# Esperamos un poquito más (0.3 seg) para que se alcance a oír el "Click" antes de matar la app
		await get_tree().create_timer(0.5).timeout 
	else:
		# Si no hay sonido, solo esperamos la animación visual pequeña (0.1)
		await get_tree().create_timer(0.1).timeout
		
	get_tree().quit()
