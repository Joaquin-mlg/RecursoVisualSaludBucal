extends Area2D

var vida_restante = 3
const MAX_VIDA = 3

# Valores de progreso a enviar
const PROGRESO_POR_GOLPE = 3.0  # 3% por cada golpe
const PROGRESO_POR_ELIMINACION = 1.0 # 1% de bono

# Precarga las texturas para cada estado de vida de la roca.
# ¡AJUSTA ESTAS RUTAS A TUS IMÁGENES REALES!
const TEXTURA_INTACTA = preload("res://game/assets/animaciones/RocaIntacta.png")
const TEXTURA_DANADA_LIGERO = preload("res://game/assets/animaciones/RocaDañadaligero.png")
const TEXTURA_DANADA_GRAVE = preload("res://game/assets/animaciones/RocaMuyDañada.png")

# Referencia a tu Sprite2D hijo para cambiar el visual.
@onready var sprite_roca = $Sprite2D

# REFERENCIA AL NODO CEPILAR (LA RAÍZ) - ¡NUEVA LÍNEA!
# Cuenta 3 padres arriba desde RocaN (Rocas -> Asteroide -> Cepillar)
@onready var root_cepillar = get_parent().get_parent().get_parent() 

func _ready():
	actualizar_textura_roca()

# Función llamada por el HiloDental para aplicar daño.
func recibir_dano_hilo_dental():
	if vida_restante > 0:
		vida_restante -= 1
		print("Vida restante de la roca: " + str(vida_restante))
		
		# 1. ENVIAR 3% AL PROGRESO - ¡NUEVA LÍNEA!
		root_cepillar.actualizar_progreso(PROGRESO_POR_GOLPE) 
		
		actualizar_textura_roca()
		
		if vida_restante == 0:
			romper_roca()

# Función para cambiar la textura del sprite según la vida actual.
func actualizar_textura_roca():
	if vida_restante == 3:
		sprite_roca.texture = TEXTURA_INTACTA
	elif vida_restante == 2:
		sprite_roca.texture = TEXTURA_DANADA_LIGERO
	elif vida_restante == 1:
		sprite_roca.texture = TEXTURA_DANADA_GRAVE

func romper_roca():
	# 2. ENVIAR 1% DE BONO AL PROGRESO - ¡NUEVA LÍNEA!
	root_cepillar.actualizar_progreso(PROGRESO_POR_ELIMINACION)
	
	# La roca se destruye
	queue_free()
