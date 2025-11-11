extends Area2D

@export var speed := 100.0

# 1. Función para reiniciar el nivel
func _reiniciar_nivel():
	# get_tree().reload_current_scene() es perfecto para reiniciar la escena actual
	get_tree().reload_current_scene()


# 2. **CAMBIO CLAVE:** Usar la señal body_entered
# Esta función se llama automáticamente cuando un CharacterBody2D
# (como tu nave) entra en el área del asteroide.
func _on_body_entered(body: Node2D) -> void:
	# Opcional pero recomendado: Verificar que el cuerpo sea el jugador
	# Asegúrate de que tu nave (CharacterBody2D) esté en el grupo "player"
	if body.is_in_group("player"): 
		print("💥 Colisión con el jugador")
		# Usar call_deferred es bueno para evitar problemas de sincronización
		call_deferred("_reiniciar_nivel")


func _process(delta):
	position.y += speed * delta
	if position.y >= 800: # fuera de pantalla
		queue_free()
