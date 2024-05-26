extends CharacterBody2D

const SPEED: float = 150.0
const JUMP_VELOCITY: float = -450.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var kill_zone: StaticBody2D = $kill_zone

@onready var sprite: AnimatedSprite2D = $sprite
@onready var outline: Sprite2D = $outline

@export var controller_port: int
@export var color: Color

signal player_killed

func _ready() -> void:
	sprite.modulate = color

func _physics_process(delta: float) -> void:
	if kill_zone.test_move(global_transform, Vector2.ZERO, null):
		emit_signal("player_killed")
		queue_free()
	
	if not is_on_floor():
		velocity.y += gravity * delta

	for event in InputMap.action_get_events("jump"):
		if event.device == controller_port && Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY

	var direction = Input.get_joy_axis(controller_port, JOY_AXIS_LEFT_X)
	if direction:
		velocity.x = direction * SPEED
		
		if velocity.x > 0:
			sprite.flip_h = false
			outline.flip_h = false
		else:
			sprite.flip_h = true
			outline.flip_h = true
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
