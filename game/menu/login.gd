extends Control
# REFERENCIAS
@onready var input_nombre = $InputNombre
@onready var label_error = $LabelError # Opcional, si creaste el label de error
# Ruta a tu menú principal
var escena_menu = "res://game/menu/main.tscn"
func _ready():
	# Opcional: Limpiar el texto de error al iniciar
	if label_error:
		label_error.text = ""
func _on_boton_continuar_pressed():
	# 1. Obtener el texto quitando espacios al inicio y final
	var nombre = input_nombre.text.strip_edges()
	
	# --- VALIDACIÓN 1: ¿Está vacío? ---
	if nombre == "":
		mostrar_error("¡Debes escribir un nombre!")
		return # Cortamos la función aquí, no avanza
	
	# --- VALIDACIÓN 2: ¿Tiene números? ---
	if _tiene_numeros(nombre):
		mostrar_error("El nombre no puede contener números.")
		return # Cortamos aquí
	
	# --- ÉXITO ---
	# Si llegamos aquí, pasó todas las pruebas
	print("Nombre válido: ", nombre)
	
	# Guardamos en la libreta global
	GlobalSettings.nombre_jugador = nombre
	
	# Cambiamos de escena
	Transicion.cambiar_escena(escena_menu)

# --- FUNCIÓN DE COMPROBACIÓN ---
func _tiene_numeros(texto: String) -> bool:
	# Recorremos el texto letra por letra
	for caracter in texto:
		# Si el caracter es un dígito del 0 al 9
		if caracter >= "0" and caracter <= "9":
			return true # ¡Encontramos un número!
	
	return false # Revisamos todo y no hubo números

# --- AYUDA VISUAL ---
func mostrar_error(mensaje: String):
	print("ERROR: ", mensaje)
	
	# Si pusiste el Label de error, muéstralo ahí
	if label_error:
		label_error.text = mensaje
		label_error.modulate = Color.RED
		
		# Animación simple de "temblor" para feedback visual (Opcional)
		var tween = create_tween()
		tween.tween_property(label_error, "position:x", label_error.position.x + 5, 0.05)
		tween.tween_property(label_error, "position:x", label_error.position.x - 5, 0.05)
		tween.tween_property(label_error, "position:x", label_error.position.x, 0.05)
