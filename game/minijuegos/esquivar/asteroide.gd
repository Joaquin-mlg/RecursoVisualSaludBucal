extends Area2D

@export var speed := 100.0

func _physics_process(delta):
	position.y += speed * delta
	
	if position.y >= 900: # Ajusta según tu pantalla
		queue_free()

func _reiniciar_nivel():
	get_tree().reload_current_scene()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("💥 Colisión con el jugador. Reiniciando...")

		if OS.has_feature("android") or OS.has_feature("ios"):
			Input.vibrate_handheld(300)

		call_deferred("_reiniciar_nivel")
