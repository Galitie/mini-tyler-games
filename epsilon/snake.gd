# LAYERS
# 1: SNAKE'S FEET
# 2: SNAKE'S BODY
# 3: WALLS
# 4: PROJECTILES
# 5: ENEMY FEET
# 6: ENEMY BODY
# 7: BOX

extends CharacterBody2D
class_name Snake

var controller_port: int = 0

const SPEED: float = 50.0
const BOX_SPEED: float = 10.0

@onready var sprite: AnimatedSprite2D = $sprite

var direction: String = "u"

enum SnakeState {IDLE, MOVE, BOX, DRAW, DRAWN, SHOOT, DEAD}
var state: SnakeState = SnakeState.IDLE

var pistol_bullet_scene: PackedScene = load("res://epsilon/pistol_bullet.tscn")

@onready var map: TileMap = get_parent().get_parent()

var hp = 10

var is_hit: bool = false
var hit_timer: float = 0.0
var hit_timer_length: float = 0.1

func _ready() -> void:
	add_to_group("snakes")
	add_to_group("entities")
	$sprite.animation_finished.connect(_animation_finished)

func _physics_process(delta: float) -> void:
	var move_input: Vector2 = Controller.GetLeftStick(controller_port)
	
	var collision: KinematicCollision2D = move_and_collide(velocity * delta, true)
	if collision:
		var entity = collision.get_collider()
		if entity.is_in_group("enemies"):
			if !entity.on_alert:
				entity.alert()
	
	if is_hit:
		modulate = Color.RED
		hit_timer += 1.0 * delta
		if hit_timer > hit_timer_length:
			is_hit = false
			hit_timer = 0.0
			modulate = Color.WHITE
	
	match state:
		SnakeState.IDLE:
			sprite.play("idle" + "_" + direction)
			if move_input.length() > 0:
				state = SnakeState.MOVE
			elif Controller.IsControllerButtonPressed(controller_port, JOY_BUTTON_X):
				sprite.play("draw" + "_" + direction, 1.0)
				state = SnakeState.DRAW
			elif Controller.GetRightTrigger(controller_port) > 0.5:
				state = SnakeState.BOX
				return
		SnakeState.MOVE:
			if move_input.length() == 0:
				state = SnakeState.IDLE
				return
			elif Controller.IsControllerButtonPressed(controller_port, JOY_BUTTON_X):
				sprite.play("draw" + "_" + direction, 1.0)
				state = SnakeState.DRAW
				return
			elif Controller.GetRightTrigger(controller_port) > 0.5:
				state = SnakeState.BOX
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
			if !Controller.IsControllerButtonPressed(controller_port, JOY_BUTTON_X):
				sprite.play("shoot" + "_" + direction, 1.0)
				state = SnakeState.SHOOT
				var bullet = pistol_bullet_scene.instantiate()
				var bullet_direction = GetVectorFromDirection(direction)
				bullet.velocity = bullet_direction * bullet.SPEED
				bullet.position = position + Vector2(0, -16) + (bullet_direction * 8)
				map.add_child(bullet)
		SnakeState.SHOOT:
			return
		SnakeState.DEAD:
			return
		SnakeState.BOX:
			$box/box_collider.disabled = false
			if Controller.GetRightTrigger(controller_port) < 0.5:
				state = SnakeState.IDLE
				$box/box_collider.disabled = true
				return
			direction = GetDirection(move_input)
			if direction.ends_with("l"):
				sprite.flip_h = true
			else:
				sprite.flip_h = false
			sprite.play("box" + "_" + direction)
			velocity = move_input * BOX_SPEED
			move_and_slide()
			
func hit(damage: int) -> void:
	hp -= damage
	is_hit = true
	if hp <= 0:
		hp = 0
		sprite.play("fall" + "_" + direction)
		$body/collider.disabled = true
		$collider.disabled = true
		state = SnakeState.DEAD
		z_index = -1

func GetDirection(move_input: Vector2) -> String:
	if move_input.length() == 0:
		return direction
	
	var angle: float = atan2(move_input.y, move_input.x)
	var octant: int = int(round(8 * angle / (2*PI) + 8)) % 8
	match octant:
		0:
			return "r"
		1:
			return "dr"
		2:
			return "d"
		3:
			return "dl"
		4:
			return "l"
		5:
			return "ul"
		6:
			return "u"
		7:
			return "ur"
			
	return "N/A"
	
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
