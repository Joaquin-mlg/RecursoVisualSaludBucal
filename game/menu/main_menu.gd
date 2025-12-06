extends Node2D

# --- CONFIGURACIÓN DE NAVEGACIÓN ---
@export_group("Navegación")
@export_file("*.tscn") var escena_juego = "res://game/historia/Historia1.tscn"
@export_file("*.tscn") var escena_ajustes = "res://game/menu/Ajustes.tscn"

# --- REFERENCIAS ---
@export_group("Referencias")
# ARRASTRA AQUÍ TUS 3 BOTONES EN EL INSPECTOR
@export var lista_botones: Array[Button] 
@onready var musica_fondo = $MusicaFondo
@onready var sfx_click = $SFXClick
@export_group("Referencias UI") # <--- Nuevo grupo para ordenar
@export var label_saludo: Label # <--- ARRASTRA AQUÍ TU NUEVO LABEL EN EL INSPECTOR
# --- CONFIGURACIÓN VISUAL (Animación) ---
@export_group("Animación Botones")
@export var factor_crecimiento: float = 1.1
@export var tiempo_animacion: float = 0.1

func _ready():
	_actualizar_saludo()
	# 1. Música
	if musica_fondo and not musica_fondo.playing:
		musica_fondo.play()
	
	# 2. Configurar TODOS los botones de la lista automáticamente
	for boton in lista_botones:
		_configurar_boton(boton)
	
	# 3. Escuchar cambios de accesibilidad
	GlobalSettings.configuracion_cambiada.connect(_actualizar_todos_los_botones)

# --- CONFIGURACIÓN AUTOMÁTICA ---
func _configurar_boton(btn: Button):
	# Ajustar pivote para que crezca desde el centro
	btn.pivot_offset = btn.size / 2
	
	# Conectar las señales de animación USANDO .bind(btn)
	# Esto le dice a la función QUÉ botón fue el que se tocó
	btn.mouse_entered.connect(_animar_crecer.bind(btn))
	btn.mouse_exited.connect(_animar_volver.bind(btn))
	btn.button_down.connect(_animar_pulsar.bind(btn))
	# Para soltar, necesitamos chequear si seguimos encima
	btn.button_up.connect(_animar_soltar.bind(btn))
	
	# Aplicar tamaño inicial
	_aplicar_tamano_accesible(btn)

func _actualizar_todos_los_botones():
	for boton in lista_botones:
		_aplicar_tamano_accesible(boton)

func _aplicar_tamano_accesible(btn: Button):
	var tam = GlobalSettings.tamanio_actual
	btn.scale = Vector2(tam, tam)
	btn.pivot_offset = btn.size / 2 # Recalcular pivote por si cambió el tamaño

# --- LÓGICA DE ANIMACIÓN GENÉRICA ---
func _animar_crecer(btn: Button):
	var escala_base = Vector2(GlobalSettings.tamanio_actual, GlobalSettings.tamanio_actual)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(btn, "scale", escala_base * factor_crecimiento, tiempo_animacion)

func _animar_volver(btn: Button):
	var escala_base = Vector2(GlobalSettings.tamanio_actual, GlobalSettings.tamanio_actual)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(btn, "scale", escala_base, tiempo_animacion)

func _animar_pulsar(btn: Button):
	var escala_base = Vector2(GlobalSettings.tamanio_actual, GlobalSettings.tamanio_actual)
	var tween = create_tween()
	tween.tween_property(btn, "scale", escala_base * 0.95, 0.05)

func _animar_soltar(btn: Button):
	if btn.is_hovered():
		_animar_crecer(btn)
	else:
		_animar_volver(btn)

# --- LÓGICA DE NAVEGACIÓN (Señales específicas) ---
# Conecta estas señales manualmente desde el nodo Main a cada botón específico

func _on_button_iniciar_pressed():
	_ir_a_escena(escena_juego, "Iniciando juego...")

func _on_button_configuracion_pressed():
	_ir_a_escena(escena_ajustes, "Ajustes...")

func _on_button_salir_pressed():
	print("Saliendo...")
	_feedback_sonoro()
	await get_tree().create_timer(0.3).timeout
	get_tree().quit()

# Función auxiliar para navegar
func _ir_a_escena(ruta: String, mensaje: String):
	print(mensaje)
	_feedback_sonoro()
	if ruta:
		Transicion.cambiar_escena(ruta)
	else:
		print("ERROR: Ruta de escena no asignada")

func _feedback_sonoro():
	if sfx_click: sfx_click.play()
	if OS.has_feature("mobile"): Input.vibrate_handheld(50)

func _actualizar_saludo():
	# Verificamos si asignaste el Label para que no de error
	if label_saludo:
		# Verificamos si hay un nombre guardado
		if GlobalSettings.nombre_jugador != "":
			label_saludo.text = "Hola, " + GlobalSettings.nombre_jugador
		else:
			# Por si acaso alguien entra directo al menú sin pasar por Login
			label_saludo.text = "Hola, Viajero"
