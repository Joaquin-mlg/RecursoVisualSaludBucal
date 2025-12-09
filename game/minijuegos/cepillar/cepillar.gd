extends Node2D

const PROGRESO_MAXIMO = 100.0
var juego_completado = false

@onready var progreso_limpieza = $UI/ProgresoLimpieza
@onready var asteroide_sprite = $Asteroide/Spriteateroide
@export var textura_asteroide_feliz: Texture2D

# --- REFERENCIA DE AUDIO ---
# Esta es tu música de fondo.
@onready var musica_fondo = $AudioStreamPlayer2D

var tiempo_inicio: int = 0
var errores: int = 0 

func _ready():
	progreso_limpieza.max_value = PROGRESO_MAXIMO
	progreso_limpieza.value = 0
	tiempo_inicio = Time.get_ticks_msec()
	add_to_group("nivel_cepillar")
	
	# --- MÚSICA DE FONDO ---
	# Arrancamos la música apenas empieza el nivel
	if musica_fondo:
		musica_fondo.play()
	else:
		push_warning("No encontré el AudioStreamPlayer2D")

	if not asteroide_sprite:
		push_warning("¡Cuidado! No se encontró el nodo del sprite.")

func actualizar_progreso(valor_a_sumar: float):
	progreso_limpieza.value += valor_a_sumar
	progreso_limpieza.value = clamp(progreso_limpieza.value, 0, PROGRESO_MAXIMO)

	if progreso_limpieza.value >= PROGRESO_MAXIMO and not juego_completado:
		juego_completado = true
		terminar_juego()

func terminar_juego():
	print("¡Nivel Completado! Generando reporte...")

	# CAMBIO VISUAL (Asteroide Feliz)
	if asteroide_sprite and textura_asteroide_feliz and asteroide_sprite.texture:
		var ancho_viejo = asteroide_sprite.texture.get_width()
		asteroide_sprite.texture = textura_asteroide_feliz
		var ancho_nuevo = asteroide_sprite.texture.get_width()
		
		if ancho_nuevo > 0:
			var factor_escala = float(ancho_viejo) / float(ancho_nuevo)
			asteroide_sprite.scale *= Vector2(factor_escala, factor_escala)
	
	# --- OPCIONAL: ¿PARAR LA MÚSICA? ---
	# Si quieres que la música pare al ganar, descomenta la siguiente línea:
		  # if musica_fondo: musica_fondo.stop()
	
	# CALCULO DE TIEMPO
	var tiempo_fin = Time.get_ticks_msec()
	var segundos_totales = (tiempo_fin - tiempo_inicio) / 1000
	
	# GlobalSettings.registrar_partida("Limpieza Asteroide", 100, segundos_totales, errores)

	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://game/historia/Historia3.tscn")
