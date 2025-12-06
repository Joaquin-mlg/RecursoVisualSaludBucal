extends Node

# Señal para avisar a todos los objetos que se actualicen
signal configuracion_cambiada

# ---------------------------------------------
# 1. CONFIGURACIÓN (ACCESIBILIDAD)
# ---------------------------------------------

# Definición de pasos (La traducción)
const OPCIONES_TAMANIO = [1.0, 1.2, 1.4, 1.6] 
const OPCIONES_VELOCIDAD = [1.0, 0.8, 0.6, 0.5] 

# Variables Públicas (Lo que usan los objetos)
var tamanio_actual: float = 1.0 
var velocidad_actual: float = 1.0
var alto_contraste_activo: bool = false

# Variables para guardar (Los índices 1-4 de los sliders)
var indice_tamanio_guardado: int = 1
var indice_velocidad_guardado: int = 1

# ---------------------------------------------
# 2. DATOS DE LA SESIÓN (REPORTE)
# ---------------------------------------------

var nombre_jugador: String = "Anonimo"
var reporte_sesion: Array = [] # Aquí guardaremos diccionarios con los datos

# ---------------------------------------------
# 3. FUNCIONES DEL SISTEMA
# ---------------------------------------------

func _ready():
	# Valores por defecto al arrancar
	actualizar_configuracion(1, 1, false)

# Esta función recibe los valores DEL SLIDER (1, 2, 3 o 4)
func actualizar_configuracion(paso_tam: int, paso_vel: int, alto_contraste: bool):
	# 1. Guardamos los índices
	indice_tamanio_guardado = paso_tam
	indice_velocidad_guardado = paso_vel
	alto_contraste_activo = alto_contraste
	
	# 2. TRADUCCIÓN: Convertimos el paso (1-4) en valor real
	tamanio_actual = OPCIONES_TAMANIO[paso_tam - 1]
	velocidad_actual = OPCIONES_VELOCIDAD[paso_vel - 1]
	
	# 3. Aplicar lógica de motor (Velocidad global del juego)
	Engine.time_scale = velocidad_actual
	
	# 4. Avisar a todos
	emit_signal("configuracion_cambiada")

# ---------------------------------------------
# 4. FUNCIONES DE REGISTRO (LA LIBRETA)
# ---------------------------------------------

# Función para registrar lo que pasó en un minijuego
func registrar_partida(nombre_juego: String, puntaje: int, tiempo_seg: int, errores: int):
	var datos_partida = {
		"juego": nombre_juego,
		"puntaje": puntaje,
		"tiempo": tiempo_seg,
		"errores": errores,
		"fecha": Time.get_datetime_string_from_system()
	}
	reporte_sesion.append(datos_partida)
	
	# --- EL CHIVATO (DEBUG) ---
	# Esto imprimirá un cuadro bonito en la consola cada vez que guardes algo
	print("\n✅ ¡DATOS GUARDADOS CORRECTAMENTE!")
	print("📂 Juego: ", nombre_juego)
	print("⭐ Puntaje: ", puntaje)
	print("⏱️ Tiempo: ", tiempo_seg, "s")
	print("❌ Errores: ", errores)
	print("📊 Total partidas en esta sesión: ", reporte_sesion.size())
	print("-------------------------------------------\n")

# Función para formatear el reporte final en texto (Para el Email)
func generar_texto_reporte() -> String:
	var texto = "REPORTE DE SESIÓN\n"
	texto += "Jugador: " + nombre_jugador + "\n"
	texto += "Fecha: " + Time.get_datetime_string_from_system() + "\n"
	texto += "Total juegos jugados: " + str(reporte_sesion.size()) + "\n"
	texto += "-----------------------------------\n"
	
	for partida in reporte_sesion:
		texto += "Juego: " + partida["juego"] + "\n"
		texto += " - Puntaje: " + str(partida["puntaje"]) + "\n"
		texto += " - Tiempo: " + str(partida["tiempo"]) + "s\n"
		texto += " - Errores: " + str(partida["errores"]) + "\n"
		texto += "-----------------------------------\n"
		
	return texto

# --- TRUCO SECRETO ---
# Si presionas la tecla "P" mientras juegas, verás todo lo guardado en la consola
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_P:
			print("\n🕵️ REVISANDO LIBRETA DE NOTAS ACTUAL:")
			print(reporte_sesion)
