extends Node2D

@export var objeto_scene: PackedScene 

@onready var spawn_point = $ContenedorObjetos/PuntoAparicion
@onready var label_puntos = $LabelPuntos 
# Audio (Opcionales, usa si tienes los nodos)
@onready var audio_fx = $AudioFX 

var lista_objetos = [
	{"nombre": "Cepillo Dental", "es_bueno": true, "texture_path": "res://game/assets/sprite/UI/Cepillo.png"},
	{"nombre": "Enjuague Bucal", "es_bueno": true, "texture_path": "res://game/assets/sprite/UI/enjuague.png"},
	{"nombre": "Hilo Dental", "es_bueno": true, "texture_path": "res://game/assets/sprite/UI/hilodental.png"},
	{"nombre": "Caramelo Pegajoso", "es_bueno": false, "texture_path": "res://game/assets/sprite/UI/caramelo.png"},
	{"nombre": "Nuez Dura", "es_bueno": false, "texture_path": "res://game/assets/sprite/UI/chicle.png"},
	{"nombre": "Chocolate", "es_bueno": false, "texture_path": "res://game/assets/sprite/UI/chocolate.png"}
]

var indice_actual = 0
var aciertos = 0
# --- VARIABLES NUEVAS PARA REPORTE ---
var errores = 0
var tiempo_inicio = 0

func _ready():
	randomize()
	lista_objetos.shuffle()
	
	# Guardar hora de inicio
	tiempo_inicio = Time.get_ticks_msec()
	
	if label_puntos:
		label_puntos.text = "Aciertos: 0"
	
	await get_tree().create_timer(1.0).timeout
	iniciar_ronda()

func iniciar_ronda():
	if indice_actual >= lista_objetos.size():
		juego_terminado()
		return
		
	spawn_objeto_actual()

func spawn_objeto_actual():
	if objeto_scene == null:
		print("ERROR: Asigna la escena ObjetoDental")
		return
		
	var nuevo_objeto = objeto_scene.instantiate()
	var datos = lista_objetos[indice_actual]
	
	nuevo_objeto.position = spawn_point.position
	$ContenedorObjetos.add_child(nuevo_objeto)
	
	nuevo_objeto.configurar(datos)
	nuevo_objeto.connect("objeto_clasificado", _on_objeto_clasificado)

func _on_objeto_clasificado(es_correcto: bool):
	if es_correcto:
		# --- ÉXITO ---
		print("¡Correcto!")
		aciertos += 1
		
		# Feedback Visual/Sonoro
		if label_puntos: label_puntos.text = "Aciertos: " + str(aciertos)
		# if audio_fx: audio_fx.play_exito() 
		if OS.has_feature("mobile"): Input.vibrate_handheld(50) # Vibración corta
		
		indice_actual += 1
		await get_tree().create_timer(0.8).timeout
		iniciar_ronda()
		
	else:
		# --- ERROR ---
		print("Incorrecto.")
		errores += 1 # Sumamos error al reporte
		
		# Feedback de Error
		# if audio_fx: audio_fx.play_error()
		if OS.has_feature("mobile"): Input.vibrate_handheld(300) # Vibración larga
		
		# El objeto se queda ahí para que el niño intente de nuevo

func juego_terminado():
	print("FIN DEL JUEGO.")
	
	# --- GENERAR REPORTE ---
	var tiempo_fin = Time.get_ticks_msec()
	var segundos_totales = (tiempo_fin - tiempo_inicio) / 1000
	
	# Calculamos puntaje: 100 pts por acierto - 10 pts por cada error
	# Aseguramos que no sea negativo con max(0, ...)
	var puntaje_final = max(0, (aciertos * 100) - (errores * 10))
	
	GlobalSettings.registrar_partida(
		"Clasificación de Alimentos", 
		puntaje_final, 
		int(segundos_totales), 
		errores
	)
	
	cargar_siguiente_escena()

func cargar_siguiente_escena():
	var siguiente_escena_ruta = "res://game/historia/Historia4.tscn"
	print("Cargando: " + siguiente_escena_ruta)
	get_tree().change_scene_to_file(siguiente_escena_ruta)
