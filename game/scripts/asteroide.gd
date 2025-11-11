extends Area2D

@export var speed := 100.0

func _process(delta):
	position.y += speed * delta
	if position.y >= 800: # fuera de pantalla
		queue_free()

func _reiniciar_nivel():
	get_tree().reload_current_scene()


func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
		print("💥 Colisión con el jugador")
		call_deferred("_reiniciar_nivel")


func _on_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
