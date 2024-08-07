extends Node2D

var bullet_scene = preload("res://epsilon/pistol_bullet.tscn")

var pistol_sfx = preload("res://epsilon/sound_effects/pistol.mp3")

var hp: int = 25

var is_destroyed: bool = false

var is_hit: bool = false
var hit_timer: float = 0.0
var hit_timer_length: float = 0.1

var direction: String = "d"

var cooldown_length: float = 7.0
var cooldown: float = cooldown_length
var bullet_rate_length: float = 0.2
var bullets_per_round: int = 3

@onready var map = get_parent().get_parent().get_parent()

func _ready() -> void:
	add_to_group("entities")
	$sprite.animation_finished.connect(_animation_finished)

func _physics_process(delta: float) -> void:
	if !is_destroyed:
		var areas: Array = get_parent().get_node("vision").get_overlapping_areas()
		for area in areas:
			var entity = area.get_parent()
			if entity.is_in_group("snakes"):
				look_at(entity.global_position)
				rotate(-PI / 2)
				var snake_direction: Vector2 = (entity.global_position - global_position).normalized()
				direction = GetDirection(snake_direction)
				break
				
		if cooldown == 0.0 && $sprite/raycast.is_colliding():
			cooldown = cooldown_length
			for i in range(bullets_per_round):
				FireBullet()
				await get_tree().create_timer(bullet_rate_length).timeout
				
		cooldown -= 1.0 * delta
		if cooldown < 0.0:
			cooldown = 0.0
				
		if direction.ends_with("r"):
			$sprite.flip_h = true
		else:
			$sprite.flip_h = false
		$sprite.play("idle" + "_" + direction)
	
	if is_hit:
		$sprite.material.set_shader_parameter("is_hit", true)
		hit_timer += 1.0 * delta
		if hit_timer > hit_timer_length:
			is_hit = false
			hit_timer = 0.0
			$sprite.material.set_shader_parameter("is_hit", false)
			
func FireBullet() -> void:
	var bullet = bullet_scene.instantiate()
	bullet.emitter = self
	bullet.speed = 150.0
	bullet.direction = ($sprite/raycast.to_global($sprite/raycast.target_position) - $sprite/raycast.to_global(Vector2.ZERO)).normalized()
	map.add_child(bullet)
	bullet.global_position = $bullet_spawn.global_position
	var sfx = get_parent().get_node("sfx")
	sfx.stream = pistol_sfx
	sfx.play()

func hit(emitter, damage: int) -> void:
	if hp >= 1:
		hp -= damage
		if hp <= 0:
			is_destroyed = true
			$sprite.play("explode")
			$body.set_deferred("monitoring", false)
			$body.set_deferred("monitorable", false)
			return
		is_hit = true
		
func _animation_finished() -> void:
	if hp <= 0:
		visible = false

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
