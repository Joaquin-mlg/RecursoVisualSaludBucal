extends Button

# --- CONFIGURACIÓN DE NAVEGACIÓN ---
@export_group("Navegación")
# Aquí arrastras tu archivo .tscn de la pantalla de ajustes
@export_file("*.tscn") var escena_ajustes: String 

# --- CONFIGURACIÓN VISUAL ---
@export_category("Animación")
@export var escala_crecimiento: Vector2 = Vector2(1.1, 1.1)
@export var tiempo_animacion: float = 0.1

# --- CONFIGURACIÓN DE AUDIO ---
@export_category("Audio")
@export var sfx_click: AudioStream # <--- Arrastra tu archivo de sonido aquí

var escala_original: Vector2
var reproductor_sonido: AudioStreamPlayer 

func _ready():
	# 1. Preparativos Visuales
	escala_original = scale
	pivot_offset = size / 2
	
	# 2. Preparativos de Audio
	reproductor_sonido = AudioStreamPlayer.new()
	add_child(reproductor_sonido)
	if sfx_click:
		reproductor_sonido.stream = sfx_click
	
	# 3. Conexiones (Señales de mouse y botón)
	mouse_entered.connect(_animar_crecer)
	mouse_exited.connect(_animar_volver)
	button_down.connect(_animar_pulsar)
	button_up.connect(_animar_soltar)
	
	# Conectamos al cambio de escena
	pressed.connect(_ir_a_ajustes)

# --- ANIMACIONES (Igual que el botón salir) ---
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

# --- LÓGICA DE CAMBIO DE ESCENA ---
# ... (Todo tu código anterior de variables y animaciones sigue igual) ...

# --- LÓGICA DE CAMBIO DE ESCENA MODIFICADA ---
func _ir_a_ajustes():
	print("Iniciando transición...")
	
	# 1. Sonido (opcional)
	if sfx_click: 
		reproductor_sonido.play()
		# No necesitamos esperar mucho aquí porque la transición tarda en ponerse negra,
		# así que el sonido se escuchará mientras la pantalla se oscurece.
	
	# 2. Verificar que hayamos puesto una escena
	if escena_ajustes != "":
		# --- AQUÍ ESTÁ EL CAMBIO MÁGICO ---
		# Llamamos a nuestro Autoload "Transicion"
		Transicion.cambiar_escena(escena_ajustes)
	else:
		print("ERROR: No has asignado la escena de ajustes en el Inspector.")
