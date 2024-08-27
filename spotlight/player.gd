extends CharacterBody2D

@export var controller_port: int = 0
@export var color: Color = Color.WHITE

var move_speed: float = 200
var jump_impulse: float = -400
var fall_speed: float = 1200
const MAX_FALL_SPEED: float = 1000

var ping_timer: float = 0
var ping_timer_length: float = 3

func _ready() -> void:
	$sprite.modulate = color
	$sonar.color = color
	#$sonar.light_mask = controller_port + 1
	#$sonar.range_item_cull_mask = controller_port + 1

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += fall_speed * delta
		if velocity.y > MAX_FALL_SPEED:
			velocity.y = MAX_FALL_SPEED

	if Controller.IsControllerButtonJustPressed(0, JOY_BUTTON_A) and is_on_floor():
		velocity.y = jump_impulse
		
	#ping_timer += 1.0 * delta
		
	#if ping_timer > ping_timer_length:
	#	ping_timer = 0
	#	$animation_player.play("ping")
		
	var direction: Vector2 = Controller.GetLeftStick(0)
	if direction:
		velocity.x = direction.x * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)

	move_and_slide()
