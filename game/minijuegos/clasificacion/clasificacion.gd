extends Node2D

@export var objeto_scene: PackedScene 

@onready var spawn_point = $ContenedorObjetos/PuntoAparicion
@onready var label_puntos = $LabelPuntos 

# --- AUDIO ---
@onready var musica_fondo = $AudioFx       # Música (Loop)
@onready var narrador = $Narrador         # Voz (Instrucciones/Feedback)

# --- CONFIGURACIÓN DE ACCESIBILIDAD ---
@export_group("Narración del Juego")
@export var audio_intro: AudioStream      # "Clasifica los objetos..."
@export var audio_acierto: AudioStream    # "¡Muy bien!"
@export var audio_error: AudioStream      # "Eso no es saludable"
@export var audio_fin_juego: AudioStream  # "¡Terminamos!"

# --- DATA DE OBJETOS ---
# CORRECCIÓN: Usamos preload() aquí para evitar errores de carga después
var lista_objetos = [
	{
		"nombre": "Cepillo Dental", 
		"es_bueno": true, 
		"texture_path": "res://game/minijuegos/cepillar/assets/CEPILLO INICIAL .png",
		"audio_nombre": preload("res://game/audio/narraciones/Cepillo.mp3") 
	},
	{
		"nombre": "Enjuague Bucal", 
		"es_bueno": true, 
		"texture_path": "res://game/minijuegos/clasificacion/Assets/EnjuagueClasifiacion.png",
		"audio_nombre": preload("res://game/audio/narraciones/Enjuague bucal.mp3")
	},
	{
		"nombre": "Hilo Dental", 
		"es_bueno": true, 
		"texture_path": "res://game/minijuegos/cepillar/assets/HiloDentalFinal.png",
		"audio_nombre": preload("res://game/audio/narraciones/Hilodental.mp3")
	},
	{
		"nombre": "Caramelo Pegajoso", 
		"es_bueno": false, 
		"texture_path": "res://game/minijuegos/clasificacion/Assets/Chupete.png",
		"audio_nombre": preload("res://game/audio/narraciones/Chupete.mp3")
	},
	{
		"nombre": "Nuez Dura", 
		"es_bueno": false, 
		"texture_path": "res://game/minijuegos/clasificacion/Assets/Chicles.png",
		"audio_nombre": preload("res://game/audio/narraciones/Chicle.mp3")
	},
	{
		"nombre": "Chocolate", 
		"es_bueno": false, 
		"texture_path": "res://game/minijuegos/clasificacion/Assets/Chocolate.png",
		"audio_nombre": preload("res://game/audio/narraciones/Chocolate.mp3")
	}
]

var indice_actual = 0
var aciertos = 0
var errores = 0
var tiempo_inicio = 0

func _ready():
	randomize()
	lista_objetos.shuffle()
	
	tiempo_inicio = Time.get_ticks_msec()
	
	if label_puntos:
		label_puntos.text = "Aciertos: 0"
	
	# 1. MÚSICA DE FONDO
	if musica_fondo:
		musica_fondo.play()
	
	# 2. INSTRUCCIÓN INICIAL
	_reproducir_voz(audio_intro)
	
	# Esperamos un poco a que termine la intro
	await get_tree().create_timer(2.0).timeout
	iniciar_ronda()

func iniciar_ronda():
	if indice_actual >= lista_objetos.size():
		juego_terminado()
		return
		
	spawn_objeto_actual()

func spawn_objeto_actual():
	if objeto_scene == null:
		print("ERROR: Asigna la escena ObjetoDental en el Inspector")
		return
		
	var nuevo_objeto = objeto_scene.instantiate()
	var datos = lista_objetos[indice_actual]
	
	nuevo_objeto.position = spawn_point.position
	$ContenedorObjetos.add_child(nuevo_objeto)
	
	nuevo_objeto.configurar(datos)
	nuevo_objeto.connect("objeto_clasificado", _on_objeto_clasificado)
	
	# --- AUDIO DEL OBJETO ---
	# Como ya usamos preload arriba, 'datos["audio_nombre"]' ya es un AudioStream
	var audio_obj = datos.get("audio_nombre")
	if audio_obj:
		_reproducir_voz(audio_obj)

func _on_objeto_clasificado(es_correcto: bool):
	if es_correcto:
		# --- ÉXITO ---
		print("¡Correcto!")
		aciertos += 1
		if label_puntos: label_puntos.text = "Aciertos: " + str(aciertos)
		
		_reproducir_voz(audio_acierto)
		
		if OS.has_feature("mobile"): 
			Input.vibrate_handheld(50) 
		
		indice_actual += 1
		await get_tree().create_timer(1.0).timeout 
		iniciar_ronda()
		
	else:
		# --- ERROR ---
		print("Incorrecto.")
		errores += 1 
		
		_reproducir_voz(audio_error)
		
		if OS.has_feature("mobile"): 
			Input.vibrate_handheld(400) 
		
		# No avanzamos, el niño debe intentar de nuevo con el mismo objeto

func _reproducir_voz(clip: AudioStream):
	if clip == null: return
	
	# Interrumpimos al narrador si ya estaba hablando
	if narrador.playing:
		narrador.stop()
		
	narrador.stream = clip
	narrador.play()

func juego_terminado():
	print("FIN DEL JUEGO.")
	
	if musica_fondo: musica_fondo.stop()
	
	# --- AUDIO FINAL ---
	_reproducir_voz(audio_fin_juego)
	
	var tiempo_fin = Time.get_ticks_msec()
	var segundos_totales = (tiempo_fin - tiempo_inicio) / 1000
	var puntaje_final = max(0, (aciertos * 100) - (errores * 10))
	
	GlobalSettings.registrar_partida("Clasificación de Alimentos", puntaje_final, int(segundos_totales), errores)
	
	# Esperar audio final
	await get_tree().create_timer(3.0).timeout
	cargar_siguiente_escena()

func cargar_siguiente_escena():
	var siguiente_escena_ruta = "res://game/historia/Historia4.tscn"
	print("Cargando: " + siguiente_escena_ruta)
	get_tree().change_scene_to_file(siguiente_escena_ruta)
