extends Node

# --- SEÑALES ---
# Esta señal avisa al sistema viejo (AccesibilidadUI)
signal configuracion_cambiada 
# Esta señal avisa a los botones nuevos para cambiar PNGs
signal high_contrast_changed(is_enabled: bool)

# --- VARIABLES ---
const OPCIONES_TAMANIO = [1.0, 1.1, 1.2, 1.3]
const OPCIONES_VELOCIDAD = [1.0, 0.8, 0.6, 0.5]

var tamanio_actual: float = 1.0
var velocidad_actual: float = 1.0

# UNIFICACIÓN: Usaremos solo esta variable para todo
var alto_contraste_activo: bool = false 

var indice_tamanio_guardado: int = 1
var indice_velocidad_guardado: int = 1

# --- REPORTE (Sin cambios, lo dejo igual) ---
var nombre_jugador: String = "Anonimo"
var reporte_sesion: Array = []

func _ready():
	actualizar_configuracion(1, 1, false)

# --- FUNCIÓN UNIFICADA PARA EL CHECKBOX ---
func set_high_contrast(enabled: bool):
	alto_contraste_activo = enabled
	
	# 1. Avisamos a los botones de texturas (Tus nuevos botones)
	high_contrast_changed.emit(alto_contraste_activo)
	
	# 2. Avisamos a la UI general (Tu sistema antiguo de escalas)
	configuracion_cambiada.emit()

# --- FUNCIÓN PARA LOS SLIDERS Y CARGA ---
func actualizar_configuracion(paso_tam: int, paso_vel: int, alto_contraste: bool):
	indice_tamanio_guardado = paso_tam
	indice_velocidad_guardado = paso_vel
	
	# Actualizamos la variable maestra
	alto_contraste_activo = alto_contraste
	
	tamanio_actual = OPCIONES_TAMANIO[paso_tam - 1]
	velocidad_actual = OPCIONES_VELOCIDAD[paso_vel - 1]
	Engine.time_scale = velocidad_actual
	
	# Emitimos ambas señales para que TODO se actualice
	configuracion_cambiada.emit()
	high_contrast_changed.emit(alto_contraste_activo)
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
