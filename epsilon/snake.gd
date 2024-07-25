# LAYERS
# 1: SNAKE'S FEET
# 2: SNAKE'S BODY
# 3: WALLS
# 4: PROJECTILES
# 5: ENEMY FEET
# 6: ENEMY BODY
# 7: BOX
# 8: DEAD SNAKE
# 9: MINES

extends CharacterBody2D
class_name Snake

signal dead

@export var controller_port: int = 0

@export var player_color: Color = Color("6868d8")

const SPEED: float = 50.0
const BOX_SPEED: float = 10.0

@onready var sprite: AnimatedSprite2D = $sprite

var direction: String = "u"

enum SnakeState {IDLE, MOVE, BOX, HELPING, DRAW, DRAWN, PUNCH, SHOOT, DEAD}
var state: SnakeState = SnakeState.IDLE

var pistol_bullet_scene: PackedScene = preload("res://epsilon/pistol_bullet.tscn")
var grenade_scene: PackedScene = preload("res://epsilon/grenade.tscn")
var stinger_missile_scene: PackedScene = preload("res://epsilon/stinger_missile.tscn")

var revive_sfx = preload("res://epsilon/sound_effects/revived.wav")
var pistol_sfx = preload("res://epsilon/sound_effects/pistol.mp3")
var grenade_draw_sfx = preload("res://epsilon/sound_effects/grenade_draw.wav")
var stinger_draw_sfx = preload("res://epsilon/sound_effects/stinger_draw.wav")
var stinger_shoot_sfx = preload("res://epsilon/sound_effects/stinger_shoot.wav")
var cqc_sfx = preload("res://epsilon/sound_effects/cqc.wav")

var map: TileMap = null

const MAX_HP: int = 10
var hp: int = 10

const PUNCH_DAMAGE: int = 1

var is_hit: bool = false
var hit_timer: float = 0.0
var hit_timer_length: float = 0.1

var weapon: String = ""
const STARTING_PISTOL_AMMO: int = 20
const STARTING_GRENADE_AMMO: int = 2
const STARTING_STINGER_AMMO: int = 4
var pistol_ammo: int = STARTING_PISTOL_AMMO
var grenade_ammo: int = STARTING_GRENADE_AMMO
var stinger_ammo: int = STARTING_STINGER_AMMO

var revive: float = 0
var can_be_revived: bool = true
var revive_max_time: float = 3.0
var snake_to_be_helped: Snake = null

@export var badge: Control

func _ready() -> void:
	sprite.material.set_shader_parameter("new", player_color)
	
	add_to_group("snakes")
	add_to_group("entities")
	$help_area.area_entered.connect(_help_entered)
	$help_area.area_exited.connect(_help_exited)
	sprite.animation_finished.connect(_animation_finished)
	$punch_area.area_entered.connect(_area_entered_punch)
	$help.visible = false
	
func Reset(_revive: bool) -> void:
	state = SnakeState.IDLE
	sprite.play("idle_u")
	direction = "u"
	revive = 0.0
	z_index = 0
	can_be_revived = true
	$help.visible = false
	$body.set_deferred("monitorable", true)
	$shadow.visible = true
	$help_area.set_deferred("monitorable", false)
	$collider.set_deferred("disabled", false)
	
	if _revive:
		hp = MAX_HP
		pistol_ammo = STARTING_PISTOL_AMMO
		stinger_ammo = STARTING_STINGER_AMMO
		grenade_ammo = STARTING_GRENADE_AMMO
	
func UpdateUI(delta: float) -> void:
	badge.get_node("hp_bar").size.x = move_toward(badge.get_node("hp_bar").size.x, float((float(hp) / float(MAX_HP)) * 24.0), 20.0 * delta)
	badge.get_node("pistol_ammo").text = "[center]" + str(pistol_ammo) + "[/center]"
	badge.get_node("stinger_ammo").text = "[center]" + str(stinger_ammo) + "[/center]"
	badge.get_node("grenade_ammo").text = "[center]" + str(grenade_ammo) + "[/center]"
	badge.get_node("profile").self_modulate = player_color
	if state == SnakeState.DEAD:
		badge.get_node("anim_player").play("dead")
	else:
		badge.get_node("anim_player").play("alive")

func _physics_process(delta: float) -> void:
	var move_input: Vector2 = Controller.GetLeftStick(controller_port)
	UpdateUI(delta)
	
	if is_hit:
		sprite.material.set_shader_parameter("is_hit", true)
		hit_timer += 1.0 * delta
		if hit_timer > hit_timer_length:
			is_hit = false
			hit_timer = 0.0
			sprite.material.set_shader_parameter("is_hit", false)
	
	match state:
		SnakeState.IDLE:
			velocity = Vector2.ZERO
			sprite.play("idle" + "_" + direction)
			if move_input.length() > 0:
				state = SnakeState.MOVE
			elif Controller.IsControllerButtonPressed(controller_port, JOY_BUTTON_X) && pistol_ammo > 0:
				weapon = "pistol"
				sprite.play(weapon + "_" + "draw" + "_" + direction, 1.0)
				state = SnakeState.DRAW
				return
			elif Controller.IsControllerButtonPressed(controller_port, JOY_BUTTON_B) && grenade_ammo > 0:
				weapon = "grenade"
				sprite.play(weapon + "_" + "draw" + "_" + direction, 1.0)
				state = SnakeState.DRAW
				$sfx.stream = grenade_draw_sfx
				$sfx.play()
				return
			elif Controller.IsControllerButtonPressed(controller_port, JOY_BUTTON_Y) && stinger_ammo > 0:
				weapon = "stinger"
				sprite.play(weapon + "_" + "draw" + "_" + direction, 1.0)
				state = SnakeState.DRAW
				$sfx.stream = stinger_draw_sfx
				$sfx.play()
				return
			elif Controller.IsControllerButtonJustPressed(controller_port, JOY_BUTTON_A):
				if snake_to_be_helped && snake_to_be_helped.can_be_revived:
					state = SnakeState.HELPING
					return
				else:
					$sfx.stream = cqc_sfx
					$sfx.play()
					punch()
					return
			elif Controller.GetRightTrigger(controller_port) > 0.5:
				state = SnakeState.BOX
				return
		SnakeState.MOVE:
			if move_input.length() == 0:
				state = SnakeState.IDLE
				return
			elif Controller.IsControllerButtonPressed(controller_port, JOY_BUTTON_X) && pistol_ammo > 0:
				weapon = "pistol"
				sprite.play(weapon + "_" + "draw" + "_" + direction, 1.0)
				state = SnakeState.DRAW
				return
			elif Controller.IsControllerButtonPressed(controller_port, JOY_BUTTON_B) && grenade_ammo > 0:
				weapon = "grenade"
				sprite.play(weapon + "_" + "draw" + "_" + direction, 1.0)
				state = SnakeState.DRAW
				$sfx.stream = grenade_draw_sfx
				$sfx.play()
				return
			elif Controller.IsControllerButtonPressed(controller_port, JOY_BUTTON_Y) && stinger_ammo > 0:
				weapon = "stinger"
				sprite.play(weapon + "_" + "draw" + "_" + direction, 1.0)
				state = SnakeState.DRAW
				$sfx.stream = stinger_draw_sfx
				$sfx.play()
				return
			elif Controller.IsControllerButtonJustPressed(controller_port, JOY_BUTTON_A):
				if snake_to_be_helped && snake_to_be_helped.can_be_revived:
					state = SnakeState.HELPING
					return
				else:
					$sfx.stream = cqc_sfx
					$sfx.play()
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
				pistol_ammo -= 1
				sprite.play(weapon + "_" + "shoot" + "_" + direction, 1.0)
				state = SnakeState.SHOOT
				var bullet = pistol_bullet_scene.instantiate()
				bullet.emitter = self
				bullet.direction = GetVectorFromDirection(direction)
				bullet.position = position + Vector2(0, -2) + (bullet.direction * 6)
				map.add_child(bullet)
				$sfx.stream = pistol_sfx
				$sfx.play()
			elif weapon == "grenade" && !Controller.IsControllerButtonPressed(controller_port, JOY_BUTTON_B):
				grenade_ammo -= 1
				sprite.play(weapon + "_" + "shoot" + "_" + direction, 1.0)
				state = SnakeState.SHOOT
				var grenade = grenade_scene.instantiate()
				grenade.emitter = self
				grenade.direction = GetVectorFromDirection(direction)
				grenade.position = position + Vector2(0, -4) + (grenade.direction * 6)
				map.add_child(grenade)
			elif weapon == "stinger" && !Controller.IsControllerButtonPressed(controller_port, JOY_BUTTON_Y):
				stinger_ammo -= 1
				sprite.play(weapon + "_" + "shoot" + "_" + direction, 1.0)
				state = SnakeState.SHOOT
				var stinger_missile = stinger_missile_scene.instantiate()
				stinger_missile.emitter = self
				stinger_missile.direction_str = direction
				stinger_missile.direction = GetVectorFromDirection(direction)
				stinger_missile.position = position + Vector2(0, -4) + (stinger_missile.direction * 7)
				map.add_child(stinger_missile)
				$sfx.stream = stinger_shoot_sfx
				$sfx.play()
		SnakeState.SHOOT:
			velocity = Vector2.ZERO
		SnakeState.DEAD:
			$help.visible = can_be_revived
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
		SnakeState.HELPING:
			sprite.play("helping")
			velocity = Vector2.ZERO
			snake_to_be_helped.BeingHelped(delta)
			if Controller.IsControllerButtonJustReleased(controller_port, JOY_BUTTON_A):
				snake_to_be_helped.get_node("help").play("empty")
				snake_to_be_helped.revive = 0.0
				state = SnakeState.IDLE
				
	move_and_slide()
	
	if state != SnakeState.DEAD:
		var camera: Camera2D = get_viewport().get_camera_2d()
		var screen_center: Vector2 = camera.get_screen_center_position()
		var camera_width: float = get_viewport_rect().end.x / camera.zoom.x
		var camera_height: float = get_viewport_rect().end.y / camera.zoom.y
		global_position.x = clampf(global_position.x, screen_center.x + 10 - camera_width / 2, screen_center.x - 10 + camera_width / 2)
		global_position.y = clampf(global_position.y, screen_center.y + 20 - camera_height / 2, screen_center.y + camera_height / 2)

func BeingHelped(delta: float) -> void:
	revive += 1.0 * delta
	$help.play("fill", $help.sprite_frames.get_frame_count("fill") / revive_max_time)
	if revive > revive_max_time:
		$help.visible = false
		state = SnakeState.IDLE
		$help_area.set_deferred("monitorable", false)
		revive = 0.0
		z_index = 0
		hp = MAX_HP
		$body.set_deferred("monitorable", true)
		$collider.set_deferred("disabled", false)
		$shadow.visible = true
		$sfx.stream = revive_sfx
		$sfx.play()

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
			emit_signal("dead")
			sprite.play("fall" + "_" + direction)
			$body.set_deferred("monitorable", false)
			$collider.set_deferred("disabled", true)
			state = SnakeState.DEAD
			$shadow.visible = false
			$help_area.set_deferred("monitorable", true)
			$help.play("empty")
			if snake_to_be_helped:
				snake_to_be_helped = null

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
			$help.visible = true
			
func _area_entered_punch(area: Area2D) -> void:
	var entity = area.get_parent()
	if entity != self && entity.is_in_group("entities"):
		entity.hit(self, PUNCH_DAMAGE)
		$punch_area.set_deferred("monitoring", false)
		$punch_area/punch_collider.position = Vector2.ZERO

func _help_entered(area: Area2D) -> void:
	snake_to_be_helped = area.get_parent()

func _help_exited(area: Area2D) -> void:
	if state == SnakeState.HELPING:
		state = SnakeState.IDLE
	snake_to_be_helped = null
