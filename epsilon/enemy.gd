extends CharacterBody2D
class_name Enemy

signal enemy_alerted
signal enemy_lost_alert

@export var patrols: Array[Node2D] = []

const WALK_SPEED: float = 20.0
const RUN_SPEED: float = 40.0

var current_patrol_index: int = 0
var direction: String = "l"

enum SoldierState {PATROL, ALERTED, ALERT, CONFUSED, LOOK_AROUND, SHOOT, DEAD}
var state: SoldierState = SoldierState.PATROL

@onready var sprite: AnimatedSprite2D = $sprite

@onready var vision_anchor: Node2D = $anchor
@onready var vision: Area2D = $anchor/vision
@onready var wall_cast: RayCast2D = $wall_cast

@onready var status: AnimatedSprite2D = $status

var on_alert: bool = false

var target: Snake = null

var pistol_bullet_scene: PackedScene = preload("res://epsilon/pistol_bullet.tscn")
var pickup_scene: PackedScene = preload("res://epsilon/pickup.tscn")

var found_sfx = preload("res://epsilon/sound_effects/found.mp3")
var drop_sfx = preload("res://epsilon/sound_effects/item_drop.wav")
var pistol_sfx = preload("res://epsilon/sound_effects/pistol.mp3")

@onready var map: TileMap = get_parent().get_parent()

var hp: int = 10

var is_hit: bool = false
var hit_timer: float = 0.0
var hit_timer_length: float = 0.1

var look_timer: float = 0
var look_timer_length: float = 1.5
var number_of_looks: int = 0
var max_amount_of_looks: int = 2

var is_cautious: bool = false

func _ready() -> void:
	# NOTE: To sync navigation agent with server
	set_physics_process(false)
	call_deferred("agent_setup")
	
	add_to_group("enemies")
	add_to_group("entities")
	$body.area_entered.connect(_area_entered)
	sprite.animation_finished.connect(_animation_finished)
	status.visible = false
	status.animation_finished.connect(_status_animation_finished)
	
func agent_setup() -> void:
	await get_tree().physics_frame
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	if is_hit:
		sprite.material.set_shader_parameter("is_hit", true)
		hit_timer += 1.0 * delta
		if hit_timer > hit_timer_length:
			is_hit = false
			hit_timer = 0.0
			sprite.material.set_shader_parameter("is_hit", false)
			
	if state != SoldierState.DEAD && !on_alert:
		if FoundEntity("snakes"):
			if target.state == Snake.SnakeState.BOX && target.velocity.length() == 0:
				pass
			else:
				alert()
	
	match state:
		SoldierState.PATROL:
			$nav_agent.target_position = patrols[current_patrol_index].global_position
			var t_direction = to_local($nav_agent.get_next_path_position()).normalized()
			direction = GetDirection(t_direction)
			if direction.ends_with("l"):
				sprite.flip_h = true
			else:
				sprite.flip_h = false
			SetVisionToDirection()
			var current_frame = sprite.get_frame()
			var current_progress = sprite.get_frame_progress()
			if is_cautious:
				sprite.play("run" + "_" + direction)
			else:
				sprite.play("walk" + "_" + direction)
			sprite.set_frame_and_progress(current_frame, current_progress)
			if is_cautious:
				velocity = t_direction * RUN_SPEED
			else:
				velocity = t_direction * WALK_SPEED
			if $nav_agent.is_target_reached():
				current_patrol_index += 1
				if current_patrol_index > patrols.size() - 1:
					current_patrol_index = 0
				state = SoldierState.LOOK_AROUND
				return
		SoldierState.ALERTED:
			on_alert = true
			velocity = Vector2.ZERO
			if !WallBetweenTarget():
				$nav_agent.target_position = target.global_position
			var t_direction = to_local($nav_agent.get_next_path_position()).normalized()
			direction = GetDirection(t_direction)
			SetVisionToDirection()
			if direction.ends_with("l"):
				sprite.flip_h = true
			else:
				sprite.flip_h = false
			sprite.play("idle" + "_" + direction)
		SoldierState.ALERT:
			if target.state == Snake.SnakeState.DEAD:
				state = SoldierState.PATROL
				target = null
				on_alert = false
				emit_signal("enemy_lost_alert")
				return
			if $nav_agent.is_target_reached():
				if global_position.distance_to(target.global_position) > 100.0:
					confused()
					state = SoldierState.CONFUSED
					return
				else:
					$nav_agent.target_position = target.global_position
			if !WallBetweenTarget():
				$nav_agent.target_position = target.global_position
			var t_direction = to_local($nav_agent.get_next_path_position()).normalized()
			direction = GetDirection(t_direction)
			SetVisionToDirection()
			if direction.ends_with("l"):
				sprite.flip_h = true
			else:
				sprite.flip_h = false
				
			var areas: Array = vision.get_overlapping_areas()
			for area in areas:
				var entity = area.get_parent()
				if entity.is_in_group("snakes"):
					wall_cast.target_position = to_local(entity.global_position)
					wall_cast.force_raycast_update()
					if !wall_cast.is_colliding():
						velocity = Vector2.ZERO
						sprite.play("shoot" + "_" + direction)
						state = SoldierState.SHOOT
						var bullet = pistol_bullet_scene.instantiate()
						bullet.emitter = self
						bullet.direction = GetVectorFromDirection(direction)
						bullet.position = position + Vector2(0, -2) + (bullet.direction * 6)
						map.add_child(bullet)
						$sfx.stream = pistol_sfx
						$sfx.play()
						return
			var current_frame: int = sprite.get_frame()
			var current_progress: float = sprite.get_frame_progress()
			velocity = t_direction * RUN_SPEED
			sprite.play("run" + "_" + direction)
			sprite.set_frame_and_progress(current_frame, current_progress)
		SoldierState.SHOOT:
			return
		SoldierState.DEAD:
			return
		SoldierState.CONFUSED:
			sprite.play("idle" + "_" + direction)
			return
		SoldierState.LOOK_AROUND:
			velocity = Vector2.ZERO
			look_timer += 1.0 * delta
			if look_timer > look_timer_length:
				look_timer = 0
				number_of_looks += 1
				if number_of_looks > max_amount_of_looks:
					number_of_looks = 0
					if !on_alert:
						state = SoldierState.PATROL
						return
				var directions: Array = ["u", "d", "l", "r"]
				var random_direction = directions.pick_random()
				while direction == random_direction:
					random_direction = directions.pick_random()
				direction = random_direction
				SetVisionToDirection()
				if direction.ends_with("l"):
					sprite.flip_h = true
				else:
					sprite.flip_h = false
			sprite.play("idle" + "_" + direction)

	move_and_slide()
	
func alert() -> void:
	on_alert = true
	status.visible = true
	status.play("alert", 1.0)
	state = SoldierState.ALERTED
	$sfx.stream = found_sfx
	$sfx.play()
	emit_signal("enemy_alerted")
	
func confused() -> void:
	status.visible = true
	status.play("huh", 1.0)
	state = SoldierState.CONFUSED
	
func FoundEntity(group: String) -> bool:
	var areas: Array = vision.get_overlapping_areas()
	for area in areas:
		var entity = area.get_parent()
		if entity.is_in_group(group):
			# NOTE: Janky fix to get the sight cast to look for feet
			target = entity
			wall_cast.target_position = to_local(entity.global_position) + Vector2(0, 12)
			wall_cast.force_raycast_update()
			if !wall_cast.is_colliding():
				return true
	return false
	
func WallBetweenTarget() -> bool:
	wall_cast.target_position = to_local(target.global_position) + Vector2(0, 12)
	wall_cast.force_raycast_update()
	if !wall_cast.is_colliding():
		return false
	else:
		return true
	
func hit(emitter, damage: int) -> void:
	if state != SoldierState.DEAD:
		hp -= damage
		is_hit = true
		if hp <= 0:
			hp = 0
			sprite.play("fall" + "_" + direction)
			state = SoldierState.DEAD
			on_alert = false
			status.visible = false
			$shadow.visible = false
		else:
			if emitter.is_in_group("snakes"):
				target = emitter
				if !on_alert:
					$nav_agent.target_position = target.global_position
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
		emit_signal("enemy_lost_alert")
		var pickup = pickup_scene.instantiate()
		pickup.global_position = global_position
		var rng = RandomNumberGenerator.new()
		var rng_result = rng.randi_range(1, 50)
		if rng_result >= 25 && rng_result < 40:
			pickup.pickup_type = Pickup.PickupType.PISTOL
		elif rng_result >= 40 && rng_result < 45:
			pickup.pickup_type = Pickup.PickupType.GRENADE
		elif rng_result >= 45 && rng_result <= 50:
			pickup.pickup_type = Pickup.PickupType.STINGER
		if pickup.pickup_type != Pickup.PickupType.NONE:
			$sfx.stream = drop_sfx
			$sfx.play()
			map.add_child(pickup)
		else:
			pickup.queue_free()
		z_index = -2
		$collider.set_deferred("disabled", true)
		await get_tree().create_timer(3.0).timeout
		queue_free()
		
func _status_animation_finished() -> void:
	if state == SoldierState.ALERTED:
		state = SoldierState.ALERT
		status.visible = false
	elif state == SoldierState.CONFUSED:
		if on_alert:
			state = SoldierState.PATROL
			status.visible = false
			on_alert = false
			target = null
			is_cautious = true
			max_amount_of_looks = 3
			look_timer_length = 0.5
			emit_signal("enemy_lost_alert")
		else:
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
