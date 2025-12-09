extends TextureRect
class_name AccessibleTextureRect

@export_group("Accesibilidad")
@export var normal_texture: Texture2D          # Arrastra aquí la imagen normal
@export var high_contrast_texture: Texture2D   # Arrastra aquí la imagen amarilla

func _ready():
	# Si se te olvidó asignar la normal en el script, usamos la que tenga el objeto puesta
	if normal_texture == null:
		normal_texture = texture
		
	GlobalSettings.high_contrast_changed.connect(_update_texture)
	# Leemos el estado actual desde tu GlobalSettings
	_update_texture(GlobalSettings.alto_contraste_activo)

func _update_texture(enabled: bool):
	if enabled and high_contrast_texture:
		texture = high_contrast_texture
	else:
		texture = normal_texture
