extends CharacterBody2D

const SPEED = 50.0

@onready var sprite: AnimatedSprite2D = $sprite

var direction: String = "d"

func _physics_process(delta):
	var move_input: Vector2 = Controller.GetLeftStick(0)
	
	var move_angle: float = rad_to_deg(move_input.angle_to_point(Vector2.ZERO))
	print(move_angle)
	print(direction)
	
	if move_input.length() > 0:
		direction = GetDirection(move_input)
		if direction.ends_with("l"):
			sprite.flip_h = true
		else:
			sprite.flip_h = false
		var anim_speed: float = move_input.length()
		anim_speed = clamp(anim_speed, 0.5, 1.0)
		var current_frame = sprite.get_frame()
		var current_progress = sprite.get_frame_progress()
		sprite.play("move" + "_" + direction, anim_speed)
		sprite.set_frame_and_progress(current_frame, current_progress)
	else:
		sprite.play("idle" + "_" + direction)

	velocity = move_input * SPEED
	move_and_slide()

func GetDirection(move_input: Vector2) -> String:
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
