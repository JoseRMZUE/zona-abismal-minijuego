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
	"#           #           ##         E   #",
	"#           #           ##             #",
	"########################################",
]


var LanceAngel_escena = preload("res://LanceAngel.tscn")

func _ready():
	construir()
	
func construir():
	construir_bloques(MAPA, Color(0.1647, 0.1412, 0.1882, 1))
	for fila in MAPA.size():
		for col in MAPA[fila].length():
			var escena = null
			match MAPA[fila][col]:
				"E":
					escena = LanceAngel_escena
			if escena:
				var nodo = escena.instantiate()
				nodo.position = Vector2(col + 0.5, fila + 0.5) * CELDA
				$Mapa.add_child(nodo)
