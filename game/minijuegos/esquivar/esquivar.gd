extends Node2D

@export var duration := 5.0  # tiempo total del minijuego

@onready var progress_bar = $ProgressBar
@onready var timer = $Timer

var elapsed := 0.0

func _ready():
	# Configurar barra
	progress_bar.max_value = duration
	progress_bar.value = 0
	
	# Configurar timer
	timer.wait_time = duration
	timer.one_shot = true
	timer.start()

func _process(delta):
	if timer.is_stopped():
		return
	
	elapsed += delta
	progress_bar.value = elapsed


func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://game/historia/Historia2.tscn")
