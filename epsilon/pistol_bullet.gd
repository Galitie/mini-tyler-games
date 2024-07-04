extends CharacterBody2D

const SPEED = 300.0

const LIFESPAN: float = 3.0
var life: float = 0.0

func _physics_process(delta: float) -> void:
	life += delta * 1.0
	if life > LIFESPAN:
		queue_free()
	
	if move_and_collide(velocity * delta):
		queue_free()
