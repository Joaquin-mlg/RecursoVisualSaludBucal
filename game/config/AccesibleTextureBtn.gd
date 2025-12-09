extends TextureButton
class_name AccessibleTextureBtn

@export_group("Texturas")
@export var normal_png: Texture2D
@export var high_contrast_png: Texture2D

func _ready():
	GlobalSettings.high_contrast_changed.connect(_update_texture)
	# OJO: Ahora leemos 'alto_contraste_activo'
	_update_texture(GlobalSettings.alto_contraste_activo)

func _update_texture(enabled: bool):
	if enabled and high_contrast_png:
		texture_normal = high_contrast_png
	else:
		texture_normal = normal_png
