extends "res://bloques.gd"
# El nivel se arma a partir del MAPA: cada "#" es un bloque.

const MAPA = [
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"                                        ",
	"#           #           ##             #",
	"#           #           ##             #",
	"########################################",
]


func _ready():
	# Piedra del templo hundido, más clara que el fondo para que se note
	# dónde se puede caminar.
	construir_bloques(MAPA, Color(0.1647, 0.1412, 0.1882, 1))  # #2A2430
