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

@export var controller_port: int = 0

const SPEED: float = 50.0
const BOX_SPEED: float = 10.0

@onready var sprite: AnimatedSprite2D = $sprite

var direction: String = "u"

enum SnakeState {IDLE, MOVE, BOX, DRAW, DRAWN, PUNCH, SHOOT, DEAD}
var state: SnakeState = SnakeState.IDLE

var pistol_bullet_scene: PackedScene = load("res://epsilon/pistol_bullet.tscn")
var grenade_scene: PackedScene = load("res://epsilon/grenade.tscn")
var stinger_missile_scene: PackedScene = load("res://epsilon/stinger_missile.tscn")

@onready var map: TileMap = get_parent().get_parent()

var hp = 10

const PUNCH_DAMAGE: int = 1

var is_hit: bool = false
var hit_timer: float = 0.0
var hit_timer_length: float = 0.1

var weapon: String = ""

func _ready() -> void:
	add_to_group("snakes")
	add_to_group("entities")
	$sprite.animation_finished.connect(_animation_finished)
	$punch_area.area_entered.connect(_area_entered_punch)

func _physics_process(delta: float) -> void:
	update(delta)
	move_and_slide()

func update(delta: float) -> void:
	var move_input: Vector2 = Controller.GetLeftStick(controller_port)
	
	if is_hit:
		modulate = Color.RED
		hit_timer += 1.0 * delta
		if hit_timer > hit_timer_length:
			is_hit = false
			hit_timer = 0.0
			modulate = Color.WHITE
	
	match state:
		SnakeState.IDLE:
			velocity = Vector2.ZERO
			sprite.play("idle" + "_" + direction)
			if move_input.length() > 0:
				state = SnakeState.MOVE
			elif Controller.IsControllerButtonPressed(controller_port, JOY_BUTTON_X):
				weapon = "pistol"
				sprite.play(weapon + "_" + "draw" + "_" + direction, 1.0)
				state = SnakeState.DRAW
				return
			elif Controller.IsControllerButtonPressed(controller_port, JOY_BUTTON_B):
				weapon = "grenade"
				sprite.play(weapon + "_" + "draw" + "_" + direction, 1.0)
				state = SnakeState.DRAW
				return
			elif Controller.IsControllerButtonPressed(controller_port, JOY_BUTTON_Y):
				weapon = "stinger"
				sprite.play(weapon + "_" + "draw" + "_" + direction, 1.0)
				state = SnakeState.DRAW
				return
			elif Controller.IsControllerButtonJustPressed(controller_port, JOY_BUTTON_A):
				punch()
				return
			elif Controller.GetRightTrigger(controller_port) > 0.5:
				state = SnakeState.BOX
				return
		SnakeState.MOVE:
			if move_input.length() == 0:
				state = SnakeState.IDLE
				return
			elif Controller.IsControllerButtonPressed(controller_port, JOY_BUTTON_X):
				weapon = "pistol"
				sprite.play(weapon + "_" + "draw" + "_" + direction, 1.0)
				state = SnakeState.DRAW
				return
			elif Controller.IsControllerButtonPressed(controller_port, JOY_BUTTON_B):
				weapon = "grenade"
				sprite.play(weapon + "_" + "draw" + "_" + direction, 1.0)
				state = SnakeState.DRAW
				return
			elif Controller.IsControllerButtonPressed(controller_port, JOY_BUTTON_Y):
				weapon = "stinger"
				sprite.play(weapon + "_" + "draw" + "_" + direction, 1.0)
				state = SnakeState.DRAW
				return
			elif Controller.IsControllerButtonJustPressed(controller_port, JOY_BUTTON_A):
				punch()
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
		SnakeState.DRAW:
			velocity = Vector2.ZERO
		SnakeState.DRAWN:
			direction = GetDirection(move_input)
			if direction.ends_with("l"):
				sprite.flip_h = true
			else:
				sprite.flip_h = false
			sprite.play(weapon + "_" + "drawn" + "_" + direction, 1.0)
			if weapon == "pistol" && !Controller.IsControllerButtonPressed(controller_port, JOY_BUTTON_X):
				sprite.play(weapon + "_" + "shoot" + "_" + direction, 1.0)
				state = SnakeState.SHOOT
				var bullet = pistol_bullet_scene.instantiate()
				bullet.emitter = self
				bullet.direction = GetVectorFromDirection(direction)
				bullet.position = position + Vector2(0, -2) + (bullet.direction * 6)
				map.add_child(bullet)
			elif weapon == "grenade" && !Controller.IsControllerButtonPressed(controller_port, JOY_BUTTON_B):
				sprite.play(weapon + "_" + "shoot" + "_" + direction, 1.0)
				state = SnakeState.SHOOT
				var grenade = grenade_scene.instantiate()
				grenade.emitter = self
				grenade.direction = GetVectorFromDirection(direction)
				grenade.position = position + Vector2(0, -4) + (grenade.direction * 6)
				map.add_child(grenade)
			elif weapon == "stinger" && !Controller.IsControllerButtonPressed(controller_port, JOY_BUTTON_Y):
				sprite.play(weapon + "_" + "shoot" + "_" + direction, 1.0)
				state = SnakeState.SHOOT
				var stinger_missile = stinger_missile_scene.instantiate()
				stinger_missile.emitter = self
				stinger_missile.direction_str = direction
				stinger_missile.direction = GetVectorFromDirection(direction)
				stinger_missile.position = position + Vector2(0, -4) + (stinger_missile.direction * 7)
				map.add_child(stinger_missile)
		SnakeState.SHOOT:
			velocity = Vector2.ZERO
		SnakeState.DEAD:
			velocity = Vector2.ZERO
		SnakeState.BOX:
			$shadow.visible = false
			$box.monitorable = true
			if Controller.GetRightTrigger(controller_port) < 0.5:
				state = SnakeState.IDLE
				$box.monitorable = false
				$shadow.visible = true
				return
			direction = GetDirection(move_input)
			if direction.ends_with("l"):
				sprite.flip_h = true
			else:
				sprite.flip_h = false
			sprite.play("box" + "_" + direction)
			velocity = move_input * BOX_SPEED
		SnakeState.PUNCH:
			velocity = Vector2.ZERO
			
func punch() -> void:
	sprite.play("cqc" + "_" + direction, 1.0)
	state = SnakeState.PUNCH
	$punch_area.set_deferred("monitoring", true)
	$punch_area/punch_collider.position = GetVectorFromDirection(direction) * 6
			
func hit(emitter, damage: int) -> void:
	if state != SnakeState.DEAD:
		hp -= damage
		is_hit = true
		if hp <= 0:
			hp = 0
			sprite.play("fall" + "_" + direction)
			$body.set_deferred("monitorable", false)
			$collider.set_deferred("disabled", true)
			state = SnakeState.DEAD
			$shadow.visible = false

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
	
func GetVectorFromDirection(_direction: String) -> Vector2:
	match _direction:
		"u":
			return Vector2.UP
		"d":
			return Vector2.DOWN
		"l":
			return Vector2.LEFT
		"r":
			return Vector2.RIGHT
		"ur":
			return Vector2(1, -1).normalized()
		"dr":
			return Vector2(1, 1).normalized()
		"dl":
			return Vector2(-1, 1).normalized()
		"ul":
			return Vector2(-1, -1).normalized()
		_:
			return Vector2.ZERO

func _animation_finished():
	match state:
		SnakeState.DRAW:
			state = SnakeState.DRAWN
		SnakeState.SHOOT:
			if weapon != "stinger":
				state = SnakeState.IDLE
		SnakeState.PUNCH:
			state = SnakeState.IDLE
			$punch_area.set_deferred("monitoring", false)
			$punch_area/punch_collider.position = Vector2.ZERO
		SnakeState.DEAD:
			z_index = -2
			
func _area_entered_punch(area: Area2D) -> void:
	var entity = area.get_parent()
	if entity != self && entity.is_in_group("entities"):
		entity.hit(self, PUNCH_DAMAGE)
		$punch_area.set_deferred("monitoring", false)
		$punch_area/punch_collider.position = Vector2.ZERO
