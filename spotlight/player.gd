extends CharacterBody2D
class_name SpotlightPlayer

signal got_key
signal escaped

@export var controller_port: int = 0

var move_speed: float = 200
var jump_impulse: float = -200
var jump_held: bool = false
const JUMP_FALLOFF: float = 0.7
const MAX_JUMP_POWER = -9000
var jump_power: float = MAX_JUMP_POWER
var fall_speed: float = 2000
const MAX_FALL_SPEED: float = 1000

var in_blue: bool = false
var in_green: bool = false
var in_red: bool = false

var has_key: bool = false
var has_escaped: bool = false

var spawn_position: Vector2
var respawning: bool = false

@onready var debug_port: int = controller_port

var base_pitch: float = 1.0

func _ready() -> void:
	add_to_group("players")
	$body.area_entered.connect(_body_area_entered)
	$sprite.animation_finished.connect(_animation_finished)
	$sonar_area.body_shape_entered.connect(_sonar_body_entered)
	$sonar_area.body_shape_exited.connect(_sonar_body_exited)
	
	collision_layer |= (1 << controller_port)
	collision_mask &= ~(1 << controller_port)
	
	match controller_port:
		0:
			$sprite.modulate = Color.WHITE
			base_pitch = 2.0
		1:
			$sprite.modulate = Color.BLUE
			base_pitch = 0.1
			$body.collision_mask |= (1 << 10)
			collision_mask |= (1 << 5)
			$sonar_area.collision_mask |= (1 << 14)
		2:
			$sprite.modulate = Color.GREEN
			base_pitch = 0.3
			$body.collision_mask |= (1 << 11)
			collision_mask |= (1 << 6)
			$sonar_area.collision_mask |= (1 << 15)
		3:
			$sprite.modulate = Color.RED
			base_pitch = 0.5
			$body.collision_mask |= (1 << 12)
			collision_mask |= (1 << 7)
			$sonar_area.collision_mask |= (1 << 16)
			
	if controller_port != 0:
		$sonar.color = $sprite.modulate
		$sonar_area.collision_layer |= (1 << controller_port)
	else:
		$sonar.color = Color.DIM_GRAY
		$body.collision_layer = 1
		$sonar_area.collision_mask = 0b00000000_00000000_00000000_00001110

func _physics_process(delta: float) -> void:
	if Controller.IsControllerButtonJustPressed(controller_port, JOY_BUTTON_B):
		print("test")
	
	if !has_escaped && !respawning:
		if !is_on_floor():
			if jump_held:
				if Controller.IsControllerButtonJustReleased(debug_port, JOY_BUTTON_A):
					jump_held = false
				jump_power *= JUMP_FALLOFF
				velocity.y += jump_power * delta
			velocity.y += fall_speed * delta
			if velocity.y > MAX_FALL_SPEED:
				velocity.y = MAX_FALL_SPEED
		else:
			jump_held = false
			jump_power = MAX_JUMP_POWER
			
		if Controller.IsControllerButtonJustPressed(debug_port, JOY_BUTTON_B):
			Honk()

		if Controller.IsControllerButtonJustPressed(debug_port, JOY_BUTTON_A) and is_on_floor():
			velocity.y = jump_impulse
			
			jump_held = true
		
		if controller_port == 0:
			in_blue = false
			in_green = false
			in_red = false
			var prev_mask = collision_mask
			$body.collision_mask = 0b10000000_00000000_00000000_10001110
			collision_mask &= ~(1 << 5) & ~(1 << 6) & ~(1 << 7)
			var spotlights = $body.get_overlapping_areas()
			if spotlights.size():
				# Layers 2, 3, 4 (spotlights)
				for spotlight in spotlights:
					if spotlight.get_collision_layer_value(2):
						in_blue = true
					elif spotlight.get_collision_layer_value(3):
						in_green = true
					elif spotlight.get_collision_layer_value(4):
						in_red = true
				
				# WHITE
				if in_red && in_green && in_blue:
					$body.collision_mask |= 0b00000000_00000000_00000001_00000000
					collision_mask |= (1 << 5) | (1 << 6) | (1 << 7)
				# BLUE
				elif in_blue && !in_green && !in_red:
					$body.collision_mask |= 0b00000000_00000000_00000010_00000000
					collision_mask |= (1 << 5)
				# GREEN
				elif !in_blue && in_green && !in_red:
					$body.collision_mask |= 0b00000000_00000000_00000100_00000000
					collision_mask |= (1 << 6)
				# RED
				elif !in_blue && !in_green && in_red:
					$body.collision_mask |= 0b00000000_00000000_00001000_00000000
					collision_mask |= (1 << 7)
				# CYAN
				elif in_blue && in_green:
					$body.collision_mask |= 0b00000000_00000000_00000000_00010000
					collision_mask |= (1 << 5) | (1 << 6)
				# YELLOW
				elif in_red && in_green:
					$body.collision_mask |= 0b00000000_00000000_00000000_00100000
					collision_mask |= (1 << 6) | (1 << 7)
				# MAGENTA
				elif in_red && in_blue:
					$body.collision_mask |= 0b00000000_00000000_00000000_01000000
					collision_mask |= (1 << 5) | (1 << 7)
			
			if prev_mask != collision_mask:
				var left_col = CollidedWithTerrain(Vector2(-5, 0) * delta)
				var right_col = CollidedWithTerrain(Vector2(5, 0) * delta)
				var top_col = CollidedWithTerrain(Vector2(0, -5) * delta)
				var bottom_col = CollidedWithTerrain(Vector2(0, 5) * delta)
				
				if left_col && right_col && top_col && bottom_col:
					respawning = true
					Shrink()
					return
			
			var other_sonars: Array = $sonar_area.get_overlapping_areas()
			if other_sonars.size():
				var depths: Array = []
				for sonar in other_sonars:
					var dist = ($sonar_area.global_position - sonar.global_position).length()
					var radii_sum = $sonar_area/shape.shape.radius + sonar.get_node("shape").shape.radius
					var depth = radii_sum - dist
					depths.push_back(depth)
				depths.sort()
				# NOTE: Godot throws error if radius is negative
				var result = $sonar_area/shape.shape.radius - depths.back()
				if result <= 0:
					result = 0
				$sonar_area/shape.shape.radius = result
			else:
				$sonar_area/shape.shape.radius = lerp($sonar_area/shape.shape.radius, 136.0, 3 * delta)
			var sonar_scalar = remap($sonar_area/shape.shape.radius, 0, 136, 0, 1)
			$sonar.scale = lerp($sonar.scale, Vector2(sonar_scalar, sonar_scalar), 15 * delta)
			
		var direction: Vector2 = Controller.GetLeftStick(debug_port)
		if direction:
			$sprite.flip_h = direction.x < 0
			velocity.x = direction.x * move_speed
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)
			
		for player in get_tree().get_nodes_in_group("players"):
			player.collision_mask |= (1 << controller_port)
				
		if is_on_floor_only():
			var slide_count = get_slide_collision_count()
			for i in range(slide_count):
				var col = get_slide_collision(i)
				if col.get_collider() is SpotlightPlayer:
					var player = col.get_collider()
					for p in get_tree().get_nodes_in_group("players"):
						if global_position.y < p.global_position.y:
							p.collision_mask &= ~(1 << controller_port)
		
		move_and_slide()
		
func Honk() -> void:
	$sprite.play("honk")
	$sfx.pitch_scale = base_pitch + randf_range(0.3, 0.6)
	$sfx.play()
	
func CollidedWithTerrain(motion: Vector2) -> bool:
	var test_col = move_and_collide(motion, true, 0.001)
	if test_col:
		if test_col.get_collider() is TileMap:
			return true
	return false

func _body_area_entered(area: Area2D) -> void:
	if area.owner is Key:
		has_key = true
		emit_signal("got_key")
		area.owner.queue_free()
	elif area.owner is Door:
		emit_signal("escaped")
		has_escaped = true
		Shrink()
	elif area.collision_layer == 0b10000000_00000000_00000000_00000000:
		respawning = true
		Shrink()
		
func Shrink() -> void:
	$shape.set_deferred("disabled", true)
	$sonar_area/shape.set_deferred("disabled", true)
	$body/shape.set_deferred("disabled", true)
	$sprite.play("shrink")
	var light_tween = get_tree().create_tween()
	light_tween.tween_property($sonar, "texture_scale", 0.0, 0.5).set_trans(Tween.TRANS_CUBIC)
	
func Spawn(spawn_pos: Vector2) -> void:
	global_position = spawn_pos
	spawn_position = global_position
	var light_tween = get_tree().create_tween()
	light_tween.tween_property($sonar, "texture_scale", 1.1, 0.5).set_trans(Tween.TRANS_QUAD)
	$shape.set_deferred("disabled", false)
	$sonar_area/shape.set_deferred("disabled", false)
	$body/shape.set_deferred("disabled", false)
	$sprite.play("default")

func _animation_finished() -> void:
	if $sprite.animation == "honk":
		$sprite.play("default")
	elif $sprite.animation == "shrink":
		if respawning:
			Spawn(spawn_position)
			respawning = false
			
func _sonar_body_entered(body_rid, _body, body_shape, _local_shape) -> void:
	if _body is TileMap:
		#var coords = _body.get_coords_for_body_rid(body_rid)
		#var tile_data: TileData = _body.get_cell_tile_data(0, coords)
		#tile_data.modulate = Color(1, 1, 1, 1)
		var layer_bitmask = PhysicsServer2D.body_get_collision_layer(body_rid)
		layer_bitmask |= (1 << 4)
		PhysicsServer2D.body_set_collision_layer(body_rid, layer_bitmask)

func _sonar_body_exited(body_rid, _body, body_shape, _local_shape) -> void:
	if _body is TileMap:
		#var coords = _body.get_coords_for_body_rid(body_rid)
		#var tile_data: TileData = _body.get_cell_tile_data(0, coords)
		#tile_data.modulate = Color(1, 1, 1, 0)
		var layer_bitmask = PhysicsServer2D.body_get_collision_layer(body_rid)
		layer_bitmask &= ~(1 << 4)
		PhysicsServer2D.body_set_collision_layer(body_rid, layer_bitmask)
