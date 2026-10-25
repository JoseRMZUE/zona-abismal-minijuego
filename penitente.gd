extends CharacterBody2D
# Zona Abismal — El Penitente
# Movimiento resuelto (mover): correr, gravedad y salto.
# Taller 3: animación real, orientación + área de golpe, ataque y rodar.

@export var speed = 220.0              # px/s
@export var gravedad = 1200.0          # px/s²
@export var salto = 560.0              # px/s hacia arriba
@export var velocidad_rodar = 400.0    # px/s mientras rueda
@export var velocidad_ataque = 1.0     # fracción de speed al atacar (1.0 = igual que correr)

@onready var sprite = $AnimatedSprite2D
@onready var golpe = $Golpe             # el área que golpea con la espada
@onready var sonido_espada = $Espada
@onready var sonido_rodar = $Rodar

var mirando = 1        # 1 = mirando a la derecha, -1 = mirando a la izquierda
var rodando = false    # true mientras dura la animación/el movimiento de rodar
var atacando = false   # true mientras dura la animación "golpe"


func _physics_process(delta):
	# Mientras rueda: movimiento propio a velocidad fija, sin leer teclado
	# (ni cambiar de dirección, ni volver a rodar, ni atacar).
	if rodando:
		velocity.x = velocidad_rodar * mirando
		if not is_on_floor():
			velocity.y += gravedad * delta
		move_and_slide()
		return

	# Mientras ataca: puede seguir corriendo, pero no saltar, rodar,
	# girar ni volver a atacar. No se llama orientar(), así que mantiene
	# hacia dónde miraba al empezar.
	if atacando:
		if not is_on_floor():
			velocity.y += gravedad * delta
		velocity.x = Input.get_axis("move_left", "move_right") * speed * velocidad_ataque
		move_and_slide()
		return

	if Input.is_action_just_pressed("rodar") and is_on_floor():
		rodar()
		return

	mover(delta)
	actualizar_animacion()
	orientar()

	if Input.is_action_just_pressed("atacar") and is_on_floor():
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
	# Se decide con is_on_floor() y la VELOCIDAD REAL (get_real_velocity()),
	# nunca con qué tecla está presionada.
	var real = get_real_velocity()
	if not is_on_floor():
		sprite.play("saltar" if real.y < 0 else "caer")
		sprite.speed_scale = 1.0
	elif abs(real.x) > 1.0:
		sprite.play("correr")
		# Nivel 3: el ritmo de las piernas va con la rapidez real.
		sprite.speed_scale = abs(real.x) / speed
		#print(sprite.speed_scale)
	else:
		sprite.play("quieto")
		sprite.speed_scale = 1.0

	#print(position.y, " ", sprite.animation)


# ---------- Nivel 2 ----------
func orientar():
	var eje = Input.get_axis("move_left", "move_right")
	if eje != 0:
		mirando = sign(eje)
	# Los sprites reales (Blasphemous) vienen dibujados mirando hacia la
	# izquierda, por eso la condición es (mirando > 0): al mirar a la
	# derecha SÍ hay que espejar el dibujo.
	sprite.flip_h = mirando > 0
	# flip_h solo espeja el DIBUJO: el área "Golpe" hay que moverla a mano.
	golpe.position.x = 50 * mirando

	#print(golpe.position.x)


# ---------- Ataque ----------
func atacar():
	atacando = true
	sprite.speed_scale = 1.0   # correr deja la velocidad de la animación en otro valor
	sprite.play("golpe")
	# Cada J debe sonar, aunque ataquen rápido: por eso NO se pregunta
	# "if not sonido_espada.playing": play() siempre reinicia el sonido.
	# Va ANTES del await: lo que está después solo corre cuando el golpe termina.
	sonido_espada.play()
	print("ataque: inicio")
	await sprite.animation_finished   # golpe tiene Loop apagado: si no, nunca termina
	atacando = false
	print("ataque: fin")


# ---------- Nivel 3 ----------
func rodar():
	rodando = true
	sprite.speed_scale = 1.0
	sprite.play("rodar")
	sonido_rodar.play()
	await sprite.animation_finished   # si "rodar" tuviera Loop activado, esto
										# nunca dispararía y quedaría rodando para siempre
	rodando = false


# La conectó el editor (señal area_entered del nodo Golpe). Se usará para
# detectar al enemigo. No borrarla: la escena la referencia.
func _on_golpe_area_entered(area: Area2D) -> void:
	pass
