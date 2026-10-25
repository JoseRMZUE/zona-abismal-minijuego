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

var vidas: int = 3
var juego_terminado: bool = false

@onready var jugador = $ElPenitente

func _ready():
	construir()
	
	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		conectar_enemigo(enemigo)
		
	if jugador and not jugador.is_in_group("jugador"):
		jugador.add_to_group("jugador")

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
				
				if not nodo.is_in_group("enemigos"):
					nodo.add_to_group("enemigos")
				conectar_enemigo(nodo)

func conectar_enemigo(enemigo):
	if enemigo.has_signal("toco_al_jugador") and not enemigo.toco_al_jugador.is_connected(_on_enemigo_toco):
		enemigo.toco_al_jugador.connect(_on_enemigo_toco)
	if enemigo.has_signal("recibio_golpe") and not enemigo.recibio_golpe.is_connected(_on_enemigo_recibio_golpe):
		enemigo.recibio_golpe.connect(_on_enemigo_recibio_golpe)

func _on_enemigo_toco(enemigo):
	if juego_terminado:
		return
		
	vidas -= 1
	print("¡El enemigo tocó al jugador! Vidas restantes: ", vidas)
	
	if vidas <= 0:
		juego_terminado = true
		print("¡Game Over! Reiniciando nivel...")
		get_tree().reload_current_scene()

func _on_enemigo_recibio_golpe(enemigo):
	print("El enemigo fue golpeado.")
