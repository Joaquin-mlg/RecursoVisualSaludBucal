extends Node2D

@export var carta_scene: PackedScene # Arrastra aquí Carta.tscn
@export var reverso_img: Texture2D # Arrastra aquí la imagen del reverso

# Diccionario de texturas (Solo visual)
# Asegúrate de que las rutas existan en tu carpeta de assets
var cartas_info = {
	"A": preload("res://game/assets/sprite/UI/CartaA_1.png"),
	"B": preload("res://game/assets/sprite/UI/CartaB_1.png"),
	"C": preload("res://game/assets/sprite/UI/CartaC_1.png"),
	"D": preload("res://game/assets/sprite/UI/CartaD_1.png")
}

@onready var grid = $UI/CenterContainer/Tablero
@onready var timer_inicio = $TimerInicio

var primera_carta = null
var segunda_carta = null
var bloqueo_input = true 

func _ready():
	generar_tablero()
	comenzar_juego()

func generar_tablero():
	# 1. Crear los pares (8 cartas en total)
	var lista_ids = ["A", "A", "B", "B", "C", "C", "D", "D"]
	lista_ids.shuffle()
	
	# 2. Instanciar las cartas en orden
	for id in lista_ids:
		var nueva_carta = carta_scene.instantiate()
		grid.add_child(nueva_carta)
		
		# Configuración visual
		nueva_carta.configurar_carta(cartas_info[id], reverso_img, id)
		nueva_carta.carta_seleccionada.connect(_procesar_seleccion)
	
	# 3. Agregar el Botón Especial (Posición 9 del Grid)
	crear_boton_especial()

func crear_boton_especial():
	var boton_esp = TextureButton.new()
	# Configura aquí la textura de tu botón "ojo" o "lupa"
	boton_esp.texture_normal = load("res://game/assets/sprite/UI/IconoAyuda.png")
	# Importante: Darle tamaño mínimo para que el Grid lo respete igual que a las cartas
	boton_esp.custom_minimum_size = Vector2(128, 128) 
	boton_esp.ignore_texture_size = true
	boton_esp.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	
	grid.add_child(boton_esp)
	boton_esp.pressed.connect(_on_boton_especial_pressed)

func comenzar_juego():
	bloqueo_input = true
	
	# Fase 1: Mostrar todas
	await get_tree().create_timer(0.5).timeout
	for carta in grid.get_children():
		if carta.has_method("voltear") and !carta.esta_volteada:
			carta.voltear()
			
	# Fase 2: Esperar 3 segundos
	timer_inicio.start()
	await timer_inicio.timeout
	
	# Fase 3: Ocultar todas
	for carta in grid.get_children():
		if carta.has_method("voltear") and carta.esta_volteada:
			carta.voltear()
			
	bloqueo_input = false

func _procesar_seleccion(carta):
	if bloqueo_input or carta == primera_carta:
		return
	
	carta.voltear()
	
	if primera_carta == null:
		primera_carta = carta
	else:
		segunda_carta = carta
		bloqueo_input = true
		verificar_pareja()

func verificar_pareja():
	await get_tree().create_timer(0.8).timeout # Pausa para ver las cartas
	
	if primera_carta.id_pareja == segunda_carta.id_pareja:
		primera_carta.emparejar_exito()
		segunda_carta.emparejar_exito()
	else:
		primera_carta.voltear()
		segunda_carta.voltear()
	
	primera_carta = null
	segunda_carta = null
	bloqueo_input = false
	
	verificar_victoria()

func verificar_victoria():
	var cartas_activas = 0
	for hijo in grid.get_children():
		# Contamos solo las cartas (ignoramos el botón especial)
		# Asumimos que 'esta_bloqueada' es true cuando ya se encontró la pareja
		if hijo.has_method("reiniciar") and not hijo.esta_bloqueada:
			cartas_activas += 1
			
	# Si ya no hay cartas activas (cartas_activas es 0), ganaste
	if cartas_activas == 0:
		print("Ganaste")
		
		# OPCIONAL: Un pequeño tiempo de espera para que el jugador vea la última pareja
		await get_tree().create_timer(1.0).timeout 
		
		# Cambio de escena
		get_tree().change_scene_to_file("res://game/historia/Historia4.tscn")
		
func _on_boton_especial_pressed():
	if bloqueo_input: return
	
	# Lógica visual: Voltear momentáneamente las cartas que faltan
	bloqueo_input = true
	
	# Voltear cara arriba
	for carta in grid.get_children():
		if carta.has_method("voltear") and !carta.esta_bloqueada and !carta.esta_volteada:
			carta.voltear()
			
	await get_tree().create_timer(1.5).timeout
	
	# Voltear cara abajo
	for carta in grid.get_children():
		if carta.has_method("voltear") and !carta.esta_bloqueada and carta.esta_volteada:
			carta.voltear()
			
	bloqueo_input = false
