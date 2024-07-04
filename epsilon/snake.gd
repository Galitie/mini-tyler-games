# LAYERS
# 1: SNAKE'S FEET
# 2: SNAKE'S BODY
# 3: WALLS
# 4: PROJECTILES
# 5: ENEMY FEET
# 6: ENEMY BODY

extends CharacterBody2D

const SPEED = 50.0

@onready var sprite: AnimatedSprite2D = $sprite

var direction: String = "u"

enum SnakeState {IDLE, MOVE, DRAW, DRAWN, SHOOT}
var state: SnakeState = SnakeState.IDLE

var pistol_bullet_scene: PackedScene = load("res://epsilon/pistol_bullet.tscn")

@onready var map: TileMap = get_parent().get_parent()

func _ready() -> void:
	$sprite.animation_finished.connect(_animation_finished)

func _physics_process(delta: float) -> void:
	var move_input: Vector2 = Controller.GetLeftStick(0)
	
	match state:
		SnakeState.IDLE:
			sprite.play("idle" + "_" + direction)
			if move_input.length() > 0:
				state = SnakeState.MOVE
			elif Controller.IsControllerButtonPressed(0, JOY_BUTTON_X):
				sprite.play("draw" + "_" + direction, 1.0)
				state = SnakeState.DRAW
		SnakeState.MOVE:
			if move_input.length() == 0:
				state = SnakeState.IDLE
				return
			elif Controller.IsControllerButtonPressed(0, JOY_BUTTON_X):
				sprite.play("draw" + "_" + direction, 1.0)
				state = SnakeState.DRAW
				return
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
			velocity = move_input * SPEED
			move_and_slide()
		SnakeState.DRAW:
			return
		SnakeState.DRAWN:
			direction = GetDirection(move_input)
			if direction.ends_with("l"):
				sprite.flip_h = true
			else:
				sprite.flip_h = false
			sprite.play("drawn" + "_" + direction, 1.0)
			if !Controller.IsControllerButtonPressed(0, JOY_BUTTON_X):
				sprite.play("shoot" + "_" + direction, 1.0)
				state = SnakeState.SHOOT
				var bullet = pistol_bullet_scene.instantiate()
				var bullet_direction = GetVectorFromDirection(direction)
				bullet.velocity = bullet_direction * bullet.SPEED
				bullet.position = position + Vector2(0, -16) + (bullet_direction * 8)
				map.add_child(bullet)
		SnakeState.SHOOT:
			return

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
	
func GetVectorFromDirection(direction: String) -> Vector2:
	match direction:
		"u":
			return Vector2.UP
		"d":
			return Vector2.DOWN
		"l":
			return Vector2.LEFT
		"r":
			return Vector2.RIGHT
		"ur":
			return Vector2(0.5, -0.5)
		"dr":
			return Vector2(0.5, 0.5)
		"dl":
			return Vector2(-0.5, 0.5)
		"ul":
			return Vector2(-0.5, -0.5)
		_:
			return Vector2.ZERO

func _animation_finished():
	match state:
		SnakeState.DRAW:
			state = SnakeState.DRAWN
		SnakeState.SHOOT:
			state = SnakeState.IDLE
