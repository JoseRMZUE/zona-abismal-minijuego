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
	construir_bloques(MAPA, Color(0.3, 0.32, 0.4, 1))
