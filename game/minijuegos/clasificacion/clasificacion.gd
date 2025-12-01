extends Node2D

@export var objeto_scene: PackedScene 

@onready var spawn_point = $ContenedorObjetos/PuntoAparicion
@onready var audio_narrador = $AudioNarrador # Asegúrate de tener estos nodos o comentarlos
@onready var audio_fx = $AudioFX
@onready var label_puntos = $LabelPuntos # Referencia a la Label que acabamos de crear

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

func _ready():
	randomize()
	lista_objetos.shuffle()
	
	# Inicializar texto
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
	
	print("JUEGO: Apareció " + datos["nombre"])

func _on_objeto_clasificado(es_correcto: bool):
	if es_correcto:
		# --- CASO DE ÉXITO ---
		print("¡Correcto!")
		aciertos += 1
		
		# Actualizar Label en pantalla
		if label_puntos:
			label_puntos.text = "Aciertos: " + str(aciertos)
		
		# Aquí: Reproducir sonido de éxito (DING)
		
		# Avanzamos al siguiente objeto
		indice_actual += 1
		
		# Esperamos un poco antes de que aparezca el siguiente
		await get_tree().create_timer(1.0).timeout
		iniciar_ronda()
		
	else:
		# --- CASO DE ERROR ---
		print("Incorrecto. Intenta de nuevo.")
		
		# Aquí: Reproducir sonido de error (BUZZ)
		# NO avanzamos el indice_actual.
		# NO llamamos a iniciar_ronda().
		# El objeto se queda en pantalla (regresó al centro por su propio script)
func cargar_siguiente_escena():
	# 2. Cargar la nueva escena
	var siguiente_escena_ruta = "res://game/historia/Historia4.tscn"
	
	# IMPORTANTE: Reemplaza la ruta de arriba con la ubicación real de tu archivo.
	
	print("¡Minijuego Completado! Cargando: " + siguiente_escena_ruta)
	
	# Usa get_tree().change_scene_to_file() para cambiar a la nueva escena
	get_tree().change_scene_to_file(siguiente_escena_ruta)
	
func juego_terminado():
	print("FIN DEL JUEGO. Total: ", aciertos)
	if label_puntos:
		label_puntos.text = "¡Juego Terminado! Total: " + str(aciertos)
		cargar_siguiente_escena()
