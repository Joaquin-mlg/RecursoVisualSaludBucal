extends Button
class_name AccessibleIconBtn

@export_group("Iconos")
@export var normal_icon: Texture2D
@export var high_contrast_icon: Texture2D

func _ready():
	GlobalSettings.high_contrast_changed.connect(_update_icon)
	# OJO: Ahora leemos 'alto_contraste_activo'
	_update_icon(GlobalSettings.alto_contraste_activo)

func _update_icon(enabled: bool):
	if enabled and high_contrast_icon:
		icon = high_contrast_icon
	else:
		icon = normal_icon
