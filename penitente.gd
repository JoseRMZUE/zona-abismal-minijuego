extends CharacterBody2D
# Zona Abismal — El Penitente
# Movimiento resuelto (mover): correr, gravedad y salto.
# Taller 3: animación real, orientación + área de golpe, ataque y rodar.

@export var speed = 220.0              # px/s
@export var gravedad = 1200.0          # px/s²
@export var salto = 560.0              # px/s hacia arriba
@export var velocidad_rodar = 400.0    # px/s mientras rueda
@export var velocidad_ataque = 1.0     # fracción de speed al atacar (1.0 = igual que correr)
@export var frame_inicio_golpe = 1     # desde qué frame de "golpe" cuenta el golpe

@onready var sprite = $AnimatedSprite2D
@onready var golpe = $Golpe             # el área que golpea con la espada
@onready var zona_golpe = $Golpe/ColorRect   # el recuadro rojo de depuración
@onready var sonido_espada = $Espada
@onready var sonido_rodar = $Rodar

var mirando = 1       # 1 = mirando a la derecha, -1 = mirando a la izquierda
var rodando = false    # true mientras dura la animación/el movimiento de rodar
var atacando = false   # true mientras dura la animación "golpe"


func _ready():
	activar_golpe(false)
	sprite.frame_changed.connect(_on_frame_changed)
	# Si la señal ya estuviera conectada desde el editor, no se conecta dos veces.
	if not golpe.area_entered.is_connected(_on_golpe_area_entered):
		golpe.area_entered.connect(_on_golpe_area_entered)


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
	# OJO: se decide con is_on_floor() y la VELOCIDAD REAL (get_real_velocity()),
	# nunca con qué tecla está presionada: si el jugador empuja una pared,
	# la tecla sigue activa pero la velocidad real en x es ~0, y debe verse "quieto".
	var real = get_real_velocity()
	if not is_on_floor():
		sprite.play("saltar" if real.y < 0 else "caer")
		sprite.speed_scale = 1.0
	elif abs(real.x) > 1.0:
		sprite.play("correr")
		# Nivel 3: el ritmo de las piernas va con la rapidez real, no siempre al 100%.
		sprite.speed_scale = abs(real.x) / speed
		print(sprite.speed_scale)
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
	# Los sprites reales (Blasphemous) vienen dibujados mirando hacia la
	# izquierda por defecto, al revés que el placeholder original, por eso
	# acá la condición queda invertida (mirando > 0) en vez de (mirando < 0):
	# cuando mira a la derecha SÍ hay que espejar el dibujo.
	sprite.flip_h = mirando > 0
	# flip_h solo espeja el DIBUJO, no mueve a los hijos (el Area2D "Golpe"
	# sigue en +50 aunque el sprite ya esté mirando a la izquierda), así que
	# hay que reposicionar el área a mano según hacia dónde mira.
	golpe.position.x = 50 * mirando

	# Evidencia para las capturas del Nivel 2:
	print(golpe.position.x)


func atacar():
	atacando = true
	sprite.speed_scale = 1.0   # correr deja la velocidad de la animación en otro valor
	sprite.play("golpe")
	# Cada J debe sonar, aunque ataquen rápido: por eso NO se pregunta
	# "if not sonido_espada.playing" antes de reproducir — play() siempre
	# reinicia el sonido desde el principio. (Si preguntáramos playing,
	# dos ataques en menos de 0.25 s solo sonarían una vez: el segundo
	# play() se saltaría porque el primero seguiría "playing".)
	sonido_espada.play()
	print("ataque: inicio")
	# Lo siguiente va DESPUÉS del sonido: lo que está bajo el await solo corre cuando el golpe termina.
	await sprite.animation_finished   # golpe tiene Loop apagado: si no, nunca termina
	atacando = false
	activar_golpe(false)
	print("atacar: fin")


# Enciende o apaga el área de golpe y su recuadro rojo.
func activar_golpe(activo):
	golpe.set_deferred("monitoring", activo)   # al final del frame, de forma segura
	zona_golpe.visible = activo


# Se ejecuta cada vez que el sprite cambia de frame.
func _on_frame_changed():
	if sprite.animation == "golpe" and sprite.frame >= frame_inicio_golpe:
		activar_golpe(true)


# Se ejecuta cuando el área de golpe toca otra área (por ahora, el ángel).
# El efecto sobre el enemigo se agrega en el siguiente paso.
func _on_golpe_area_entered(area: Area2D) -> void:
	print("golpe toco: ", area.name)
	if area.has_method("recibir_daño"):
		area.recibir_daño(1)


# ---------- Nivel 3 ----------
func rodar():
	rodando = true
	sprite.speed_scale = 1.0
	sprite.play("rodar")
	sonido_rodar.play()
	await sprite.animation_finished   # si "rodar" tuviera Loop activado, esto
										# nunca dispararía y quedaría rodando para siempre
	rodando = false
