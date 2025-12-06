extends Node2D

@export var asteroide_scene: PackedScene
@export var spawn_rate := 1.5
var timer := 0.0

func _process(delta):
	timer += delta
	if timer >= spawn_rate:
		timer = 0.0
		var a = asteroide_scene.instantiate()
		a.position = Vector2(randi_range(50, 1920), -50)
		get_tree().current_scene.add_child(a)
