# GlobalSettings.gd
extends Node

signal configuracion_cambiada

# --- DEFINICIÓN DE LOS PASOS (LA TRADUCCIÓN) ---
# Paso 1 (Default), Paso 2, Paso 3, Paso 4
const OPCIONES_TAMANIO = [1.0, 1.2, 1.4, 1.6] 
# Velocidad: Normal, un poco lento, más lento, muy lento (ideal accesibilidad)
const OPCIONES_VELOCIDAD = [1.0, 0.8, 0.6, 0.5] 

# --- VARIABLES PÚBLICAS (Lo que usan los objetos) ---
var tamanio_actual: float = 1.0 
var velocidad_actual: float = 1.0
var alto_contraste_activo: bool = false

# --- VARIABLES PARA GUARDAR (Los índices 1-4 de los sliders) ---
var indice_tamanio_guardado: int = 1
var indice_velocidad_guardado: int = 1

func _ready():
	# Valores por defecto al arrancar
	actualizar_configuracion(1, 1, false)

# Esta función recibe los valores DEL SLIDER (1, 2, 3 o 4)
func actualizar_configuracion(paso_tam: int, paso_vel: int, alto_contraste: bool):
	# 1. Guardamos los índices para que el menú sepa dónde poner el slider al volver
	indice_tamanio_guardado = paso_tam
	indice_velocidad_guardado = paso_vel
	alto_contraste_activo = alto_contraste
	
	# 2. TRADUCCIÓN: Convertimos el paso (1-4) en valor real
	# Restamos 1 porque los Arrays empiezan en 0
	tamanio_actual = OPCIONES_TAMANIO[paso_tam - 1]
	velocidad_actual = OPCIONES_VELOCIDAD[paso_vel - 1]
	
	# 3. Aplicar lógica de motor
	Engine.time_scale = velocidad_actual
	
	# 4. Avisar a todos
	emit_signal("configuracion_cambiada")
	# --- DATOS DE LA SESIÓN ---
var nombre_jugador: String = "Anonimo"
var reporte_sesion: Array = [] # Aquí guardaremos diccionarios con los datos

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
	print("Partida registrada: ", datos_partida)

# Función para formatear el reporte final en texto
func generar_texto_reporte() -> String:
	var texto = "REPORTE DE SESIÓN\n"
	texto += "Jugador: " + nombre_jugador + "\n"
	texto += "Total juegos jugados: " + str(reporte_sesion.size()) + "\n"
	texto += "-----------------------------------\n"
	
	for partida in reporte_sesion:
		texto += "Juego: " + partida["juego"] + "\n"
		texto += " - Puntaje: " + str(partida["puntaje"]) + "\n"
		texto += " - Tiempo: " + str(partida["tiempo"]) + "s\n"
		texto += " - Errores: " + str(partida["errores"]) + "\n"
		texto += "-----------------------------------\n"
		
	return texto
