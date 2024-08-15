extends CharacterBody2D

const SPEED: float = 250.0
const JUMP_VELOCITY: float = -450.0
const DASH_VELOCITY: float = 500.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var invincible: bool = true
@onready var kill_zone: StaticBody2D = $kill_zone

@onready var sprite: AnimatedSprite2D = $sprite
@onready var outline: Sprite2D = $outline

@export var controller_port: int
@export var color: Color

signal player_killed

func _ready() -> void:
	$timer.start()
	sprite.modulate = color

func _physics_process(delta: float) -> void:
	
	if kill_zone.test_move(global_transform, Vector2.ZERO, null) and not invincible:
		var rockman = self
		emit_signal("player_killed", rockman)
		queue_free()

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if Controller.IsControllerButtonJustPressed(controller_port, JOY_BUTTON_A):
			velocity.y = JUMP_VELOCITY
	
	var direction: float = Controller.GetLeftStick(controller_port).x
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


func _on_timer_timeout():
	invincible = false
