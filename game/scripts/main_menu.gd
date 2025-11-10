extends Node2D


func _ready():
	$CanvasLayer/Control/Button.pressed.connect(_on_start_pressed)

func _on_start_pressed():
	get_tree().change_scene_to_file("res://game/historia/Historia1.tscn")


func _on_button_iniciar_pressed() -> void:
	pass # Replace with function body.
