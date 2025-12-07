extends Node2D

const PROGRESO_MAXIMO = 100.0
var juego_completado = false

@onready var progreso_limpieza = $UI/ProgresoLimpieza

# --- NUEVAS REFERENCIAS VISUALES ---
# 1. Necesitas referencia al nodo que tiene la imagen del asteroide.
# Ajusta la ruta ("$AsteroideSprite") al nombre real de tu nodo en la escena.
@onready var asteroide_sprite = $Asteroide/Spriteateroide

# 2. Variable exportada para cargar la imagen feliz desde el inspector de Godot.
# Arrastra el archivo de la imagen feliz (ej. image_33.png) a esta ranura en el inspector.
@export var textura_asteroide_feliz: Texture2D


# --- VARIABLES PARA EL REPORTE ---
var tiempo_inicio: int = 0
var errores: int = 0 # Puedes sumar errores si usan la herramienta incorrecta (opcional)

func _ready():
	progreso_limpieza.max_value = PROGRESO_MAXIMO
	progreso_limpieza.value = 0

	# Guardamos la hora de inicio para calcular cuánto tardó el niño
	tiempo_inicio = Time.get_ticks_msec()

	# Asegúrate de agregar este nodo al grupo para que las Rocas lo encuentren fácil
	add_to_group("nivel_cepillar")
	
	# Verificación de seguridad
	if not asteroide_sprite:
		push_warning("¡Cuidado! No se encontró el nodo '$AsteroideSprite'. Revisa el nombre en el script.")

func actualizar_progreso(valor_a_sumar: float):
	progreso_limpieza.value += valor_a_sumar
	progreso_limpieza.value = clamp(progreso_limpieza.value, 0, PROGRESO_MAXIMO)

	# Condición de Victoria
	if progreso_limpieza.value >= PROGRESO_MAXIMO and not juego_completado:
		juego_completado = true
		terminar_juego()

func terminar_juego():
	print("¡Nivel Completado! Generando reporte...")

	# --- CAMBIO VISUAL CON CORRECCIÓN DE TAMAÑO ---
	if asteroide_sprite and textura_asteroide_feliz and asteroide_sprite.texture:
		# 1. Recordar el tamaño de la imagen TRISTE (ancho)
		var ancho_viejo = asteroide_sprite.texture.get_width()
		
		# 2. Cambiar la textura a la FELIZ (ahora se ve gigante)
		asteroide_sprite.texture = textura_asteroide_feliz
		
		# 3. Obtener el tamaño de la imagen FELIZ (ancho)
		var ancho_nuevo = asteroide_sprite.texture.get_width()
		
		# 4. Calcular el factor de corrección.
		# Si la nueva es el doble de grande, el factor será 0.5 para reducirla a la mitad.
		var factor_escala = float(ancho_viejo) / float(ancho_nuevo)
		
		# 5. Aplicar ese factor a la escala actual del sprite.
		# Multiplicamos para mantener cualquier escala que ya tuviera puesta en el editor.
		asteroide_sprite.scale *= Vector2(factor_escala, factor_escala)
	
	
	# --- EL RESTO DEL CÓDIGO SIGUE IGUAL ---
	# 1. Calcular tiempo
	var tiempo_fin = Time.get_ticks_msec()
	var segundos_totales = (tiempo_fin - tiempo_inicio) / 1000
	# ... etc ...
	# ... etc ...
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://game/historia/Historia3.tscn")
