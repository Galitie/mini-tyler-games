extends CharacterBody2D

@export var controller_port: int = 0

var move_speed: float = 200
var jump_impulse: float = -400
var fall_speed: float = 1200
const MAX_FALL_SPEED: float = 1000

var in_blue: bool = false
var in_green: bool = false
var in_red: bool = false

var prev_color: Color = Color.WHITE
var next_color: Color = Color.WHITE
const COLOR_CHANGE_SPEED: float = 12.0

func _ready() -> void:
	match controller_port:
		0:
			$sprite.modulate = Color.WHITE
		1:
			$sprite.modulate = Color.BLUE
		2:
			$sprite.modulate = Color.GREEN
		3:
			$sprite.modulate = Color.RED
			
	if controller_port != 0:
		$sonar.color = $sprite.modulate
		$sonar_area.collision_layer = controller_port + 1
	else:
		$body.collision_layer = 1
		$sonar.visible = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += fall_speed * delta
		if velocity.y > MAX_FALL_SPEED:
			velocity.y = MAX_FALL_SPEED

	if Controller.IsControllerButtonJustPressed(0, JOY_BUTTON_A) and is_on_floor():
		velocity.y = jump_impulse
	
	if controller_port == 0:		
		var spotlights = $body.get_overlapping_areas()
		in_blue = false
		in_green = false
		in_red = false
		for spotlight in spotlights:
			match spotlight.collision_layer:
				2:
					in_blue = true
				3:
					in_green = true
				4:
					in_red = true
	
		prev_color = $sprite.modulate
		if in_red && in_green:
			next_color = Color.YELLOW
		if in_red && in_blue:
			next_color = Color.MAGENTA
		if in_blue && in_green:
			next_color = Color.CYAN
		if in_red && in_green && in_blue:
			next_color = Color.WHITE
			
		$sprite.modulate = lerp(prev_color, next_color, COLOR_CHANGE_SPEED * delta)
		
	var direction: Vector2 = Controller.GetLeftStick(0)
	if direction:
		velocity.x = direction.x * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)

	move_and_slide()
