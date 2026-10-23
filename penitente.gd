extends CharacterBody2D
# Zona Abismal — El Penitente
# Movimiento resuelto (mover): correr, gravedad y salto.
# Taller 3: animación real, orientación + área de golpe, ataque y rodar.

@export var speed = 220.0              # px/s
@export var gravedad = 1200.0          # px/s²
@export var salto = 560.0              # px/s hacia arriba

@onready var sprite = $AnimatedSprite2D
@onready var golpe = $Golpe             # el área que golpea con la espada
@onready var sonido_espada = $Espada

var mirando = 1       # 1 = mirando a la derecha, -1 = mirando a la izquierda


func _physics_process(delta):
	mover(delta)
	actualizar_animacion()
	orientar()

	if Input.is_action_just_pressed("atacar"):
		atacar()


func mover(delta):
	if not is_on_floor():
		velocity.y += gravedad * delta
	if Input.is_action_just_pressed("saltar") and is_on_floor():
		velocity.y = -salto
	velocity.x = Input.get_axis("move_left", "move_right") * speed
	move_and_slide()


# ---------- Nivel 1 ----------
func actualizar_animacion():
	# OJO: se decide con is_on_floor() y la VELOCIDAD REAL (get_real_velocity()),
	# nunca con qué tecla está presionada: si el jugador empuja una pared,
	# la tecla sigue activa pero la velocidad real en x es ~0, y debe verse "quieto".
	var real = get_real_velocity()
	if not is_on_floor():
		sprite.play("saltar" if real.y < 0 else "caer")
		sprite.speed_scale = 1.0
	elif abs(real.x) > 1.0:
		sprite.play("correr")
		sprite.speed_scale = abs(real.x) / speed
	else:
		sprite.play("quieto")
		sprite.speed_scale = 1.0

	# Evidencia para las capturas del Nivel 1 (quítenlo o coméntenlo después):
	print(position.y, " ", sprite.animation)


# ---------- Nivel 2 ----------
func orientar():
	var eje = Input.get_axis("move_left", "move_right")
	if eje != 0:
		mirando = sign(eje)
	# El placeholder de la base mira a la derecha por defecto, así que
	# solo hay que espejar el dibujo cuando mira a la izquierda.
	sprite.flip_h = mirando < 0
	# flip_h solo espeja el DIBUJO, no mueve a los hijos (el Area2D "Golpe"
	# sigue en +36 aunque el sprite ya esté mirando a la izquierda), así que
	# hay que reposicionar el área a mano según hacia dónde mira.
	golpe.position.x = 36 * mirando

	# Evidencia para las capturas del Nivel 2:
	print(golpe.position.x)


func atacar():
	# Cada J debe sonar, aunque ataquen rápido: por eso NO se pregunta
	# "if not sonido_espada.playing" antes de reproducir — play() siempre
	# reinicia el sonido desde el principio. (Si preguntáramos playing,
	# dos ataques en menos de 0.25 s solo sonarían una vez: el segundo
	# play() se saltaría porque el primero seguiría "playing".)
	sonido_espada.play()
