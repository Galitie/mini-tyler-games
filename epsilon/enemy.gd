extends CharacterBody2D
class_name Enemy

@export var navs: Array[Node2D] = []

const WALK_SPEED: float = 20.0
const RUN_SPEED: float = 40.0

var current_nav_index: int = 0
var direction: String = "l"

enum SoldierState {PATROL, ALERTED, ALERT, CONFUSED, SHOOT, DEAD}
var state: SoldierState = SoldierState.PATROL

@onready var sprite: AnimatedSprite2D = $sprite

@onready var vision_anchor: Node2D = $anchor
@onready var vision: Area2D = $anchor/vision
@onready var wall_cast: RayCast2D = $wall_cast

@onready var status: AnimatedSprite2D = $status

var on_alert: bool = false

var target: Snake = null

var pistol_bullet_scene: PackedScene = load("res://epsilon/pistol_bullet.tscn")

@onready var map: TileMap = get_parent().get_parent()

var hp: int = 10

var is_hit: bool = false
var hit_timer: float = 0.0
var hit_timer_length: float = 0.1

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("entities")
	$body.area_entered.connect(_area_entered)
	sprite.animation_finished.connect(_animation_finished)
	status.visible = false
	status.animation_finished.connect(_status_animation_finished)

func _physics_process(delta: float) -> void:
	if is_hit:
		sprite.modulate = Color.RED
		hit_timer += 1.0 * delta
		if hit_timer > hit_timer_length:
			is_hit = false
			hit_timer = 0.0
			sprite.modulate = Color.WHITE
	
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
	
			var areas: Array = vision.get_overlapping_areas()
			for area in areas:
				var entity = area.get_parent()
				if entity.is_in_group("snakes"):
					# NOTE: Janky fix to get the sight cast to look for feet
					target = entity
					wall_cast.target_position = to_local(entity.global_position) + Vector2(0, 12)
					wall_cast.force_raycast_update()
					if !wall_cast.is_colliding():
						if entity.state == Snake.SnakeState.BOX && entity.velocity.length() == 0:
							pass
						else:
							alert()
							return
		SoldierState.ALERTED:
			on_alert = true
			velocity = Vector2.ZERO
			var target_dir = (target.global_position - global_position).normalized()
			direction = GetDirection(target_dir)
			SetVisionToDirection()
			if direction.ends_with("l"):
				sprite.flip_h = true
			else:
				sprite.flip_h = false
			sprite.play("idle" + "_" + direction)
		SoldierState.ALERT:
			# NOTE: Set a desired target at a time for an enemy, and set them back to patrol state
			# after they lose sight of their last target.
			var target_dir = (target.global_position - global_position).normalized()
			var target_dest = global_position + (target_dir * global_position.distance_to(target.global_position))
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
				bullet.emitter = self
				bullet.direction = GetVectorFromDirection(direction)
				bullet.position = position + Vector2(0, -14) + (bullet.direction * 6)
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
		SoldierState.DEAD:
			return
		SoldierState.CONFUSED:
			sprite.play("idle" + "_" + direction)
			return

	move_and_slide()
	
func alert() -> void:
	on_alert = true
	status.visible = true
	status.play("alert", 1.0)
	state = SoldierState.ALERTED
	
func confused() -> void:
	status.visible = true
	status.play("huh", 1.0)
	state = SoldierState.CONFUSED
	
func hit(emitter, damage: int) -> void:
	if state != SoldierState.DEAD:
		target = emitter
		hp -= damage
		is_hit = true
		if hp <= 0:
			hp = 0
			sprite.play("fall" + "_" + direction)
			state = SoldierState.DEAD
			on_alert = false
		else:
			if !on_alert:
				alert()
	
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
	elif state == SoldierState.DEAD:
		z_index = -1
		process_mode = Node.PROCESS_MODE_DISABLED
		
func _status_animation_finished() -> void:
	if state == SoldierState.ALERTED:
		state = SoldierState.ALERT
		status.visible = false
	elif state == SoldierState.CONFUSED:
		alert()

func _area_entered(area: Area2D) -> void:
	var entity = area.get_parent()
	if entity.is_in_group("snakes"):
		if state != SoldierState.DEAD && !on_alert:
			if entity.state != Snake.SnakeState.BOX:
				target = entity
				alert()
			else:
				confused()
