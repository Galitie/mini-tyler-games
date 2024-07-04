extends CharacterBody2D

@export var navs: Array[Node2D] = []

const SPEED: float = 20.0

var current_nav_index: int = 0
var direction: String = "d"

@onready var sprite: AnimatedSprite2D = $sprite

func _physics_process(delta: float) -> void:
	var nav: Node2D = navs[current_nav_index]
	
	if global_position.distance_to(nav.global_position) > 1:
		velocity = (nav.global_position - global_position).normalized() * SPEED
		direction = GetDirection(velocity)
		print(direction)
		sprite.play("walk" + "_" + direction)
	else:
		current_nav_index += 1
		if current_nav_index > navs.size() - 1:
			current_nav_index = 0

	move_and_slide()

func GetDirection(move_input: Vector2) -> String:
	if move_input.length() == 0:
		return direction
	var move_angle: float = rad_to_deg(move_input.angle())
	if move_angle > (-90 - 22.5) && move_angle < (-90 + 22.5):
		return "u"
	elif move_angle > (-45 - 22.5) && move_angle < (-45 + 22.5):
		return "ur"
	elif move_angle > (0 - 22.5) && move_angle < (0 + 22.5):
		return "r"
	elif move_angle > (45 - 22.5) && move_angle < (45 + 22.5):
		return "dr"
	elif move_angle > (90 - 22.5) && move_angle < (90 + 22.5):
		return "d"
	elif move_angle > (135 - 22.5) && move_angle < (135 + 22.5):
		return "dl"
	elif move_angle > (180 - 22.5) && move_angle < (180 + 22.5):
		return "l"
	elif move_angle > (-135 - 22.5) && move_angle < (-135 + 22.5):
		return "ul"
	return direction
