extends Area2D

var vida_restante = 3
const MAX_VIDA = 3


# --- AJUSTE DE PORCENTAJES ---
# Cada golpe con el hilo dental suma 3%
const PROGRESO_POR_GOLPE = 3.0  
# Al romperse (después del 3er golpe) suma el 1% restante para completar el 10%
const PROGRESO_POR_ELIMINACION = 1.0
# (Tus constantes de texturas se mantienen igual...)
const TEXTURA_INTACTA = preload("res://game/assets/animaciones/RocaIntacta.png")
const TEXTURA_DANADA_LIGERO = preload("res://game/assets/animaciones/RocaDañadaligero.png")
const TEXTURA_DANADA_GRAVE = preload("res://game/assets/animaciones/RocaMuyDañada.png")

@onready var sprite_roca = $Sprite2D

# Variable para guardar la referencia al jefe
var root_cepillar = null

func _ready():
	actualizar_textura_roca()
	
	# BÚSQUEDA SEGURA DEL JEFE
	# Buscamos el primer nodo que esté en el grupo "nivel_cepillar"
	root_cepillar = get_tree().get_first_node_in_group("nivel_cepillar")
	
	if root_cepillar == null:
		print("ERROR CRÍTICO: No encontré el nodo 'Cepillar'. Revisa los grupos.")

func recibir_dano_hilo_dental():
	if vida_restante > 0:
		vida_restante -= 1
		
		# Feedback Táctil (Accesibilidad) cada vez que golpea la roca
		if OS.has_feature("mobile"):
			Input.vibrate_handheld(50) 
		
		# Enviar progreso si encontramos al jefe
		if root_cepillar:
			root_cepillar.actualizar_progreso(PROGRESO_POR_GOLPE)
		
		actualizar_textura_roca()
		
		if vida_restante == 0:
			romper_roca()

func actualizar_textura_roca():
	# (Tu lógica visual está perfecta, se queda igual)
	if vida_restante == 3:
		sprite_roca.texture = TEXTURA_INTACTA
	elif vida_restante == 2:
		sprite_roca.texture = TEXTURA_DANADA_LIGERO
	elif vida_restante == 1:
		sprite_roca.texture = TEXTURA_DANADA_GRAVE

func romper_roca():
	if root_cepillar:
		root_cepillar.actualizar_progreso(PROGRESO_POR_ELIMINACION)
	
	# Vibración más fuerte al romper
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(100) 
		
	queue_free()
