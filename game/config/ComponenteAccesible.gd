extends Control
class_name AccesibilidadUI

# Mantenemos el pivote para que escale desde el centro
func _ready():
	pivot_offset = size / 2
	GlobalSettings.configuracion_cambiada.connect(aplicar_cambios)
	aplicar_cambios()

func aplicar_cambios():
	# SOLO ajustamos la escala.
	# Ya no tocamos el 'modulate' porque tus TextureButtons 
	# ya se encargan de cambiar la imagen ellos mismos.
	var escala = GlobalSettings.tamanio_actual
	scale = Vector2(escala, escala)
