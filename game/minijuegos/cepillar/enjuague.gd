extends Area2D

var is_dragging = false
var drag_offset = Vector2.ZERO
var is_spraying = false # Bandera para saber si está tocando el Asteroide
var posicion_inicial: Vector2 
var tween: Tween 

func _ready():
	posicion_inicial = global_position 

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				if tween and tween.is_running():
					tween.kill()
				is_dragging = true
				drag_offset = global_position - event.global_position

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
			if is_dragging:
				is_spraying = false # Detener la limpieza al soltar
				is_dragging = false
				regresar_suavemente() 
	
	if event is InputEventMouseMotion and is_dragging:
		global_position = event.global_position + drag_offset

func _process(delta):
	# Limpieza continua mientras el enjuague está sobre el Asteroide
	if is_spraying:
		var asteroide_node = get_tree().root.get_node("Cepillar/Asteroide") 
		if asteroide_node:
			# Llama a la nueva función de "claridad" en el Asteroide
			asteroide_node.recibir_enjuague(delta)

func regresar_suavemente():
	tween = create_tween()
	tween.tween_property(self, "global_position", posicion_inicial, 0.3)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)

# CONECTAR estas señales en el Editor.
func _on_area_entered(area: Area2D) -> void:
	if area.name == "AreaEnjuague":
		is_spraying = true

func _on_area_exited(area: Area2D) -> void:
	if area.name == "AreaEnjuague":
		is_spraying = false
