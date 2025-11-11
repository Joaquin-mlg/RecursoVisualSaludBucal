extends Area2D # <-- ¡Correcto para un obstáculo detector!

@export var speed := 100.0

# Función para manejar el movimiento del asteroide
func _process(delta):
	position.y += speed * delta
	if position.y >= 800: # Ajustar 800 a la coordenada fuera de la vista
		queue_free()

# Función para reiniciar el nivel (llamada diferida para seguridad)
func _reiniciar_nivel():
	# get_tree().reload_current_scene() es la forma más rápida de reiniciar
	get_tree().reload_current_scene()

# Esta es la señal correcta para conectar al Player (CharacterBody2D)
func _on_body_entered(body: Node2D) -> void:
 	# Asegúrate de que tu Player (CharacterBody2D) esté en el grupo "player" en el Inspector
	if body.is_in_group("player"):	
		print("💥 Colisión con el jugador. Reiniciando...")
		# 📱 Implementar la vibración (verás que Godot la simula en el editor)
		if OS.has_feature("android") or OS.has_feature("ios"):
			Input.vibrate_handheld(300) # 300 ms de vibración
		
		# Llamada diferida para evitar problemas durante la física
		call_deferred("_reiniciar_nivel")
	
# NOTA: Elimina la función _on_body_shape_entered y _on_body_entered vacía 
# si no están conectadas a una señal. Usa solo la función conectada: _on_body_entered
