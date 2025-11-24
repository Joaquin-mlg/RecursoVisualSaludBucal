extends Area2D

signal objeto_clasificado(es_correcto)

var arrastrando = false
var es_bueno = false 
var posicion_inicial

func _ready():
	posicion_inicial = global_position

func configurar(datos):
	es_bueno = datos["es_bueno"]
	
	if FileAccess.file_exists(datos["texture_path"]):
		$Sprite2D.texture = load(datos["texture_path"])
	else:
		# Debug si no hay imagen
		if has_node("Label"):
			$Label.text = datos["nombre"]
		$Sprite2D.modulate = Color.GREEN if es_bueno else Color.RED

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.pressed:
			arrastrando = true
			scale = Vector2(1.2, 1.2)
			z_index = 10 

func _input(event):
	if not arrastrando:
		return

	if (event is InputEventMouseButton or event is InputEventScreenTouch) and not event.pressed:
		arrastrando = false
		scale = Vector2(1.0, 1.0)
		z_index = 0
		verificar_donde_cayo()

func _process(_delta):
	if arrastrando:
		global_position = get_global_mouse_position()

func verificar_donde_cayo():
	var areas_colisionadas = get_overlapping_areas()
	var soltado_en_zona = false
	
	for area in areas_colisionadas:
		if area.is_in_group("zona_buena"):
			soltado_en_zona = true
			validar_resultado(es_bueno == true) # Si es bueno y está en zona buena = true
			return 
			
		elif area.is_in_group("zona_mala"):
			soltado_en_zona = true
			validar_resultado(es_bueno == false) # Si es malo (false) y está en zona mala = true
			return

	# Si no cayó en ninguna zona, regresa
	if not soltado_en_zona:
		regresar_al_centro()

func validar_resultado(acerto: bool):
	# Avisamos al script principal si acertó o falló (para sonidos y puntos)
	emit_signal("objeto_clasificado", acerto)
	
	if acerto:
		# SI ACERTÓ: Se elimina el objeto para que venga el siguiente
		queue_free()
	else:
		# SI FALLÓ: No se elimina. Regresa al centro para intentar de nuevo.
		regresar_al_centro()

func regresar_al_centro():
	var tween = create_tween()
	# Animación elástica de regreso al centro
	tween.tween_property(self, "global_position", posicion_inicial, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
