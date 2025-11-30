extends Button

# Configuración
@export var escala_crecimiento: Vector2 = Vector2(1.1, 1.1) # Crece un 10%
@export var tiempo_animacion: float = 0.1

# Guardamos la escala original por si acaso la cambiaste en el editor
var escala_original: Vector2

func _ready():
	escala_original = scale
	
	# TRUCO PRO: Ajustar el punto de pivote al centro automáticamente.
	# Si no hacemos esto, el botón crecerá hacia la derecha y abajo, viéndose mal.
	pivot_offset = size / 2
	
	# Conectamos las señales por código para no hacerlo manual
	mouse_entered.connect(_al_entrar_mouse)
	mouse_exited.connect(_al_salir_mouse)
	button_down.connect(_al_pulsar) # Efecto extra al tocar
	button_up.connect(_al_soltar)   # Efecto al soltar
	GlobalSettings.configuracion_cambiada.connect(_actualizar_accesibilidad)
	_actualizar_accesibilidad()

func _actualizar_accesibilidad():
	# Actualizamos la escala BASE.
	# Nota: Como tu animación de botón ya modifica la escala, 
	# deberás modificar la variable 'escala_original' en vez de 'scale' directamente
	# para que la animación de "hover" parta desde el nuevo tamaño.
	var nuevo_tam = GlobalSettings.tamanio_botones
	scale = Vector2(nuevo_tam, nuevo_tam)
	
	# Actualizar variable para animaciones
	escala_original = Vector2(nuevo_tam, nuevo_tam)
# Cuando el mouse entra (o tocas en Android)
func _al_entrar_mouse():
	var tween = create_tween()
	# Transición "Spring" para que haga un pequeño rebote elástico
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT) 
	tween.tween_property(self, "scale", escala_crecimiento, tiempo_animacion)

# Cuando el mouse sale (o dejas de tocar)
func _al_salir_mouse():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", escala_original, tiempo_animacion)

# Efecto extra: Al hacer clic se encoge un poquito (feedback táctil)
func _al_pulsar():
	var tween = create_tween()
	tween.tween_property(self, "scale", escala_original * 0.95, 0.05)

func _al_soltar():
	# Al soltar vuelve al tamaño "grande" si el mouse sigue encima
	_al_entrar_mouse()
