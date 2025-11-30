extends CanvasLayer

@onready var anim = $AnimationPlayer
@onready var rect = $ColorRect

func _ready():
	# Nos aseguramos de que sea invisible al empezar
	rect.visible = false

func cambiar_escena(ruta_escena: String):
	# 1. Hacemos visible el telón y bajamos (fade in negro)
	rect.visible = true
	anim.play("disolver")
	
	# Esperamos a que la animación termine (se ponga negro)
	await anim.animation_finished
	
	# 2. Cambiamos la escena detrás del telón
	get_tree().change_scene_to_file(ruta_escena)
	
	# 3. Subimos el telón (fade out, reproducimos al revés)
	anim.play_backwards("disolver")
	
	# Cuando termine, escondemos el rect para que no estorbe
	await anim.animation_finished
	rect.visible = false
