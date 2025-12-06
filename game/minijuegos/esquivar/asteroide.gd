extends Area2D

@export var speed := 150.0

func _physics_process(delta):
	position.y += speed * delta
	if position.y >= 1000: 
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("💥 Colisión con el jugador.")

		if OS.has_feature("android") or OS.has_feature("ios"):
			Input.vibrate_handheld(300)
		
		# --- CAMBIO IMPORTANTE ---
		# En lugar de reiniciar aquí a lo bruto, llamamos a la función
		# de Game Over del nivel principal para que él guarde los datos.
		
		# Obtenemos el nodo raíz de la escena actual (Esquivar)
		var nivel_principal = get_tree().current_scene
		
		# Si el nivel tiene la función "terminar_juego", la ejecutamos
		if nivel_principal.has_method("terminar_juego"):
			nivel_principal.terminar_juego()
		else:
			# Respaldo por si olvidaste poner el script en el main
			print("ERROR: El nivel principal no tiene función terminar_juego")
			get_tree().reload_current_scene()
