extends CharacterBody2D
# Zona Abismal — El Penitente
# Movimiento resuelto (mover): correr, gravedad y salto.
# Taller 3: animación real, orientación + área de golpe, ataque y rodar.

@export var speed = 220.0              # px/s
@export var gravedad = 1200.0          # px/s²
@export var salto = 560.0              # px/s hacia arriba

@onready var sprite = $AnimatedSprite2D
@onready var golpe = $Golpe             # el área que golpea con la espada


func _physics_process(delta):
	mover(delta)
	actualizar_animacion()


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
