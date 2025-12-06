extends Area2D

signal objeto_clasificado(es_correcto)

var arrastrando = false
var es_bueno = false 
var posicion_inicial

# --- ACCESIBILIDAD ---
var escala_base = Vector2(1, 1) # Guardaremos el tamaño configurado aquí

func _ready():
	posicion_inicial = global_position
	
	# 1. Aplicar tamaño según GlobalSettings
	var tam = GlobalSettings.tamanio_actual
	escala_base = Vector2(tam, tam)
	scale = escala_base

func configurar(datos):
	es_bueno = datos["es_bueno"]
	
	if FileAccess.file_exists(datos["texture_path"]):
		$Sprite2D.texture = load(datos["texture_path"])
	else:
		if has_node("Label"): $Label.text = datos["nombre"]
		$Sprite2D.modulate = Color.GREEN if es_bueno else Color.RED

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.pressed:
			arrastrando = true
			
			# Efecto de "Levantar" (Crece un 20% respecto a su base)
			var escala_arrastre = escala_base * 1.2
			
			# Usamos un Tween rápido para que se vea suave al agarrar
			var tween = create_tween()
			tween.tween_property(self, "scale", escala_arrastre, 0.1)
			
			z_index = 10 

func _input(event):
	if not arrastrando:
		return
		
	if (event is InputEventMouseButton or event is InputEventScreenTouch) and not event.pressed:
		# AL SOLTAR
		arrastrando = false
		z_index = 0
		
		# Vuelve a su tamaño base (grande o pequeño según config)
		var tween = create_tween()
		tween.tween_property(self, "scale", escala_base, 0.1)
		
		verificar_donde_cayo()

func _process(_delta):
	# Interpolación simple para que el objeto siga al mouse suavemente (opcional)
	# Si prefieres que sea instantáneo usa: global_position = get_global_mouse_position()
	if arrastrando:
		global_position = global_position.lerp(get_global_mouse_position(), 25 * _delta)

func verificar_donde_cayo():
	var areas_colisionadas = get_overlapping_areas()
	var soltado_en_zona = false
	
	for area in areas_colisionadas:
		# Importante: Asegúrate que tus zonas tengan estos GRUPOS
		if area.is_in_group("zona_buena"):
			soltado_en_zona = true
			validar_resultado(es_bueno == true) 
			return 
			
		elif area.is_in_group("zona_mala"):
			soltado_en_zona = true
			validar_resultado(es_bueno == false)
			return
			
	if not soltado_en_zona:
		regresar_al_centro()

func validar_resultado(acerto: bool):
	emit_signal("objeto_clasificado", acerto)
	
	if acerto:
		queue_free()
	else:
		regresar_al_centro()

func regresar_al_centro():
	var tween = create_tween()
	tween.tween_property(self, "global_position", posicion_inicial, 0.5)\
		.set_trans(Tween.TRANS_ELASTIC)\
		.set_ease(Tween.EASE_OUT)
