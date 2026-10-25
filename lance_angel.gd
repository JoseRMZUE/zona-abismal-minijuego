extends Area2D

signal toco_al_jugador(enemigo)
signal recibio_golpe(enemigo)

@export var vida_maxima: int = 3
var vida_actual: int
var muriendo: bool = false

@onready var sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D # Ajusta el nombre si tu nodo de colisión se llama diferente (ej: CollisionShape2D)

func _ready() -> void:
	vida_actual = vida_maxima
	
	if not is_in_group("enemigos"):
		add_to_group("enemigos")
		
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node2D) -> void:
	if muriendo:
		return
	if body.name == "ElPenitente" or body.is_in_group("penitente"):
		emit_signal("toco_al_jugador", self)

func recibir_daño(cantidad: int):
	if muriendo:
		return
		
	vida_actual -= cantidad
	emit_signal("recibio_golpe", self)
	print("¡Enemigo dañado! Vida restante: ", vida_actual)
	
	if vida_actual <= 0:
		morir()

func morir():
	if muriendo:
		return
	muriendo = true
	print("¡El enemigo ha sido derrotado!")
	
	# 1. Desactivar interacciones físicas y colisiones al instante
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	
	# Si tienes un CollisionShape2D directo como hijo, desactívalo también de forma segura:
	for child in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.set_deferred("disabled", true)
	
	# 2. Reproducir la animación de muerte si existe
	if sprite and sprite.sprite_frames.has_animation("morir"):
		sprite.play("morir")
		await sprite.animation_finished
	else:
		# Por si la animación no se encuentra, damos un pequeño respiro antes de borrar
		await get_tree().create_timer(0.5).timeout
		
	# 3. Eliminar completamente el nodo de la escena
	queue_free()
