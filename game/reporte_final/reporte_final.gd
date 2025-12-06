extends Control

# Referencias a los nodos de la UI
@onready var vista_previa = $VistaPrevia
@onready var btn_whatsapp = $VBoxContainer/BtnWhatsapp
@onready var btn_correo = $VBoxContainer/BtnCorreo
@onready var btn_copiar = $VBoxContainer/BtnCopiar
@onready var btn_salir = $VBoxContainer/BtnSalir

# Aquí guardaremos el texto que generó tu script Global
var texto_final_reporte = ""

func _ready():
	# 1. LLAMADA MAESTRA:
	# Aquí es donde usamos tu función "generar_texto_reporte"
	# Asumo que tu Autoload se llama "GlobalSettings"
	if GlobalSettings:
		texto_final_reporte = GlobalSettings.generar_texto_reporte()
	else:
		texto_final_reporte = "Error: No se encontró GlobalSettings"
	
	# 2. Mostrarlo en el cuadro de texto para que el tutor lo vea
	if vista_previa:
		vista_previa.text = texto_final_reporte
	
	# 3. Conectar los botones
	btn_whatsapp.pressed.connect(_on_whatsapp_pressed)
	btn_correo.pressed.connect(_on_correo_pressed)
	btn_copiar.pressed.connect(_on_copiar_pressed)
	btn_salir.pressed.connect(_on_salir_pressed)

# --- BOTÓN WHATSAPP ---
func _on_whatsapp_pressed():
	# Añadimos un saludo amistoso antes del reporte técnico
	var saludo = "Hola, comparto el progreso de " + GlobalSettings.nombre_jugador + ":\n\n"
	var mensaje_completo = saludo + texto_final_reporte
	
	# Codificamos y abrimos
	var url = "https://wa.me/?text=" + mensaje_completo.uri_encode()
	OS.shell_open(url)

# --- BOTÓN CORREO ---
func _on_correo_pressed():
	var asunto = "Reporte de Jungla Mágica: " + GlobalSettings.nombre_jugador
	
	# Codificamos asunto y cuerpo
	var asunto_safe = asunto.uri_encode()
	var cuerpo_safe = texto_final_reporte.uri_encode()
	
	# Abrimos la app de correo vacía para que el tutor ponga el destinatario
	var url = "mailto:?subject=%s&body=%s" % [asunto_safe, cuerpo_safe]
	OS.shell_open(url)

# --- BOTÓN COPIAR ---
func _on_copiar_pressed():
	DisplayServer.clipboard_set(texto_final_reporte)
	btn_copiar.text = "¡Copiado!"
	await get_tree().create_timer(1.5).timeout
	btn_copiar.text = "Copiar al Portapapeles"

# --- BOTÓN SALIR ---
func _on_salir_pressed():
	# Borra los datos si quieres que la próxima sesión empiece limpia
	# GlobalSettings.reporte_sesion.clear() 
	
	# Cambia a tu menú principal
	get_tree().change_scene_to_file("res://game/menu/main.tscn")
