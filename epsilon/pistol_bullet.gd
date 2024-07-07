extends CharacterBody2D

const SPEED = 300.0

const LIFESPAN: float = 3.0
var life: float = 0.0

const DAMAGE: int = 2

func _physics_process(delta: float) -> void:
	life += delta * 1.0
	if life > LIFESPAN:
		queue_free()
	
	var collision: KinematicCollision2D = move_and_collide(velocity * delta)
	if collision:
		if collision.get_collider().get_parent().is_in_group("entities"):
			collision.get_collider().get_parent().hit(DAMAGE)
		queue_free()
