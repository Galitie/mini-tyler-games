extends CharacterBody2D

const SPEED: float = 150.0
const JUMP_VELOCITY: float = -450.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var kill_zone: StaticBody2D = $kill_zone

@onready var sprite: AnimatedSprite2D = $sprite

func _physics_process(delta: float) -> void:
	if kill_zone.test_move(global_transform, Vector2.ZERO, null, 0.01):
		print("squish")
		queue_free()
	
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		
		if velocity.x > 0:
			sprite.flip_h = false
		else:
			sprite.flip_h = true
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
