extends Area2D

var is_dragging = false
var drag_offset = Vector2.ZERO
var posicion_inicial: Vector2 # Posición de retorno
var tween: Tween # Para la animación suave de retorno

func _ready():
	# Guardamos la posición inicial al inicio del juego
	posicion_inicial = global_position 

# Arrastrar herramienta
func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				# Detenemos cualquier Tween que esté corriendo antes de iniciar el arrastre
				if tween and tween.is_running():
					tween.kill()
				is_dragging = true
				drag_offset = global_position - event.global_position

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
			# Si soltamos el ratón, detenemos el arrastre y regresamos suavemente
			if is_dragging:
				is_dragging = false
				regresar_suavemente()
	
	if event is InputEventMouseMotion and is_dragging:
		global_position = event.global_position + drag_offset

# Función para la animación de retorno suave
func regresar_suavemente():
	tween = create_tween()
	# Duración: 0.3 segundos.
	tween.tween_property(self, "global_position", posicion_inicial, 0.3)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)

# Detección de Colisión (debe estar conectada la señal 'area_entered' al script)
func _on_area_entered(area):
	# Llama a la función de daño de la roca
	if area.is_in_group("rocas"):
		area.recibir_dano_hilo_dental()
