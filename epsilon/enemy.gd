extends CharacterBody2D

@export var navs: Array[Node2D] = []

const WALK_SPEED: float = 20.0
const RUN_SPEED: float = 40.0

var current_nav_index: int = 0
var direction: String = "l"

enum SoldierState {PATROL, ALERTED, ALERT, SHOOT}
var state: SoldierState = SoldierState.PATROL

@onready var sprite: AnimatedSprite2D = $sprite

@onready var vision_anchor: Node2D = $anchor
@onready var vision: CharacterBody2D = $anchor/vision
@onready var wall_cast: RayCast2D = $wall_cast

@onready var status: AnimatedSprite2D = $status

@onready var snake = get_parent().get_node("snake")

var pistol_bullet_scene: PackedScene = load("res://epsilon/pistol_bullet.tscn")

@onready var map: TileMap = get_parent().get_parent()

func _ready() -> void:
	sprite.animation_finished.connect(_animation_finished)
	status.visible = false
	status.animation_finished.connect(_status_animation_finished)

func _physics_process(delta: float) -> void:
	match state:
		SoldierState.PATROL:
			var nav: Node2D = navs[current_nav_index]
		
			if global_position.distance_to(nav.global_position) > 1:
				velocity = (nav.global_position - global_position).normalized() * WALK_SPEED
				direction = GetDirection(velocity)
				if direction.ends_with("l"):
					sprite.flip_h = true
				else:
					sprite.flip_h = false
				SetVisionToDirection()
				var current_frame = sprite.get_frame()
				var current_progress = sprite.get_frame_progress()
				sprite.play("walk" + "_" + direction)
				sprite.set_frame_and_progress(current_frame, current_progress)
			else:
				current_nav_index += 1
				if current_nav_index > navs.size() - 1:
					current_nav_index = 0
	
			if vision.move_and_collide(Vector2.ZERO, true):
				wall_cast.target_position = to_local(snake.global_position)
				if !wall_cast.is_colliding():
					status.visible = true
					status.play("alert", 0.8)
					state = SoldierState.ALERTED
					return
		SoldierState.ALERTED:
			velocity = Vector2.ZERO
			var target_dir = (snake.global_position - global_position).normalized()
			direction = GetDirection(target_dir)
			SetVisionToDirection()
			if direction.ends_with("l"):
				sprite.flip_h = true
			else:
				sprite.flip_h = false
			sprite.play("idle" + "_" + direction)
		SoldierState.ALERT:
			var target_dir = (snake.global_position - global_position).normalized()
			var target_dest = global_position + (target_dir * global_position.distance_to(snake.global_position))
			direction = GetDirection(target_dir)
			SetVisionToDirection()
			if direction.ends_with("l"):
				sprite.flip_h = true
			else:
				sprite.flip_h = false
			if global_position.distance_to(target_dest) < 80:
				velocity = Vector2.ZERO
				sprite.play("shoot" + "_" + direction)
				state = SoldierState.SHOOT
				var bullet = pistol_bullet_scene.instantiate()
				var bullet_direction = GetVectorFromDirection(direction)
				bullet.velocity = bullet_direction * bullet.SPEED
				bullet.position = position + Vector2(0, -16) + (bullet_direction * 8)
				map.add_child(bullet)
				return
			else:
				var current_frame = sprite.get_frame()
				var current_progress = sprite.get_frame_progress()
				velocity = target_dir.normalized() * RUN_SPEED
				sprite.play("run" + "_" + direction)
				sprite.set_frame_and_progress(current_frame, current_progress)
		SoldierState.SHOOT:
			return

	move_and_slide()
	
func SetVisionToDirection() -> void:
	match direction:
		"u":
			vision_anchor.rotation_degrees = 180
		"ur":
			vision_anchor.rotation_degrees = -135
		"ul":
			vision_anchor.rotation_degrees = 135
		"d":
			vision_anchor.rotation_degrees = 0
		"dl":
			vision_anchor.rotation_degrees = 45
		"dr":
			vision_anchor.rotation_degrees = -45
		"l":
			vision_anchor.rotation_degrees = 90
		"r":
			vision_anchor.rotation_degrees = -90

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

func _animation_finished() -> void:
	if state == SoldierState.SHOOT:
		state = SoldierState.ALERT
		
func _status_animation_finished() -> void:
	if state == SoldierState.ALERTED:
		state = SoldierState.ALERT
	status.visible = false
