extends CharacterBody2D
# Movimiento resuelto: correr, gravedad y salto. El Taller 3 se escribe abajo.

@export var speed = 220.0       # px/s
@export var gravedad = 1200.0   # px/s²
@export var salto = 560.0       # px/s hacia arriba

@onready var sprite = $AnimatedSprite2D
@onready var golpe = $Golpe     # el área que golpea con la espada


func _physics_process(delta):
	mover(delta)
	# Taller 3: aquí van la animación, la orientación, el ataque y el rodar.


func mover(delta):
	if not is_on_floor():
		velocity.y += gravedad * delta
	if Input.is_action_just_pressed("saltar") and is_on_floor():
		velocity.y = -salto
	velocity.x = Input.get_axis("move_left", "move_right") * speed
	move_and_slide()
