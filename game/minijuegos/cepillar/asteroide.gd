extends Area2D

# ---------------------------------------------
# 1. DECLARACIÓN DE VARIABLES Y REFERENCIAS
# ---------------------------------------------

# Asume que el nodo raíz se llama "Cepillar"
@onready var root_cepillar = get_tree().root.get_node("Cepillar") 
@onready var suciedad_sprite = $Suciedad # Sprite de la mancha superior

# --- Lógica del Cepillo (Suciedad) ---
const VELOCIDAD_LIMPIEZA = 0.2 
const PROGRESO_TOTAL_ASTEROIDE = 50.0 
var suciedad_restante = 1.0 # 1.0 = 100% Suciedad (transparencia del sprite)

# --- Lógica del Enjuague Bucal ---
const PROGRESO_TOTAL_ENJUAGUE = 40.0 
const VELOCIDAD_ENJUAGUE = 0.8
var opacidad_actual = 1.0 # 1.0 = Oscuro; 0.0 = Claro

# ---------------------------------------------
# 2. FUNCIONES DE INICIALIZACIÓN Y CEPILLO
# ---------------------------------------------

func _ready():
	# Configuración inicial del color (ej: un gris oscuro para representar suciedad)
	# Usamos lerp para establecer el color inicial basado en opacidad_actual = 1.0
	self.modulate = Color.BLACK.lerp(Color.WHITE, 0.5) 
	
	# Asegura que el sprite de suciedad sea totalmente visible
	suciedad_sprite.modulate.a = 1.0

# Función llamada por el Cepillo
func recibir_limpieza_degradada(delta):
	if suciedad_restante > 0:
		var cantidad_limpiada = VELOCIDAD_LIMPIEZA * delta
		var progreso_a_sumar = cantidad_limpiada * PROGRESO_TOTAL_ASTEROIDE
		
		if suciedad_restante - cantidad_limpiada < 0:
			progreso_a_sumar = suciedad_restante * PROGRESO_TOTAL_ASTEROIDE
			suciedad_restante = 0.0
			limpieza_completa()
			return
		
		suciedad_restante -= cantidad_limpiada
		suciedad_sprite.modulate.a = suciedad_restante
		root_cepillar.actualizar_progreso(progreso_a_sumar)

func limpieza_completa():
	print("Suciedad de Asteroide eliminada (Cepillo).")
	suciedad_sprite.modulate.a = 0.0

# ---------------------------------------------
# 3. FUNCIONES DE ENJUAGUE BUCAL (CORREGIDO)
# ---------------------------------------------

# Función llamada por el Enjuague Bucal
func recibir_enjuague(delta):
	if opacidad_actual > 0:
		var cantidad_aplicada = VELOCIDAD_ENJUAGUE * delta
		var progreso_a_sumar = cantidad_aplicada * PROGRESO_TOTAL_ENJUAGUE
		
		if opacidad_actual - cantidad_aplicada < 0:
			progreso_a_sumar = opacidad_actual * PROGRESO_TOTAL_ENJUAGUE
			opacidad_actual = 0.0
			enjuague_completo()
			return
		
		opacidad_actual -= cantidad_aplicada
		
		# CORRECCIÓN CLAVE: Invertimos la lógica visual para que aclare.
		# 1. Definimos el estado final limpio (Color.WHITE) y el estado inicial oscuro (Color.BLACK).
		# 2. Usamos el valor 'opacidad_actual' (que va de 1.0 a 0.0) para interpolar.
		#    Un valor de 1.0 (inicio) lo dejará más oscuro.
		#    Un valor de 0.0 (final) lo dejará Color.WHITE (limpio).
		
		var color_limpio = Color.WHITE
		var color_sucio = Color.BLACK.lerp(color_limpio, 0.5) # Color inicial oscuro/sucio
		
		# Aquí usamos la opacidad para ir de color_sucio (1.0) a color_limpio (0.0)
		self.modulate = color_sucio.lerp(color_limpio, 1.0 - opacidad_actual)
		
		root_cepillar.actualizar_progreso(progreso_a_sumar)

func enjuague_completo():
	print("Asteroide totalmente claro (Enjuague). ¡Nivel completado!")
	self.modulate = Color.WHITE # Aseguramos el color final
	
	# Deshabilitar el AreaEnjuague para que no siga detectando colisión
	if is_instance_valid(get_node_or_null("AreaEnjuague")):
		get_node("AreaEnjuague").set_monitoring(false)
