extends CharacterBody2D

var grenade_scene = preload("res://epsilon/grenade.tscn")
var missile_scene = preload("res://epsilon/metalgear_stinger.tscn")

var multi_explosion_sfx = preload("res://epsilon/sound_effects/multi_explosion.mp3")
var whiteout_sfx = preload("res://epsilon/sound_effects/whiteout.mp3")

@onready var map = get_parent()

var cooldown_length: float = 10.0
var cooldown: float = cooldown_length

var missile_cooldown_length: float = 14.0
var missile_cooldown: float = missile_cooldown_length

const MAX_HP: int = 5
var hp: int = MAX_HP

var is_hit: bool = false
var hit_timer: float = 0.0
var hit_timer_length: float = 0.1

@onready var boss_hp_bar = get_parent().get_parent().get_parent().get_node("camera/ui/camera_space/boss_life")
@onready var boss_hp = boss_hp_bar.get_node("hp")

func _ready() -> void:
	add_to_group("entities")
	boss_hp_bar.visible = true
	boss_hp.size.x = float((float(hp) / float(MAX_HP)) * 77.0)
	$anim_player.play("idle", -1.0, 1.5)
	$engine_sfx.play()

func _physics_process(delta: float) -> void:
	boss_hp.size.x = move_toward(boss_hp.size.x, float((float(hp) / float(MAX_HP)) * 77.0), 20.0 * delta)
	
	if hp > 0:
		if cooldown == 0.0:
			cooldown = cooldown_length
			$hatch.play("open")
			await get_tree().create_timer(0.4).timeout
			$grenade_sfx.play()
			await get_tree().create_timer(0.6).timeout
			var grenade_instance = grenade_scene.instantiate()
			var grenade = grenade_instance.get_node("grenade")
			grenade.marker = true
			grenade.emitter = self
			var snakes: Array = []
			for snake in get_tree().get_nodes_in_group("snakes"):
				if snake.state != Snake.SnakeState.DEAD:
					snakes.append(snake)
			if snakes.size() > 0:
				grenade.direction = -($hatch.global_position - snakes.pick_random().global_position).normalized()
			else:
				grenade.direction = Vector2(0, 1)
			grenade.global_position = $face.global_position + Vector2(0, 2) + (grenade.direction * 6)
			map.add_child(grenade_instance)
			await get_tree().create_timer(1.0).timeout
			$hatch.play("default")
			
		cooldown -= 1.0 * delta
		if cooldown < 0.0:
			cooldown = 0.0
			
		if missile_cooldown == 0.0:
			missile_cooldown = missile_cooldown_length
			$module.play("open")
			await get_tree().create_timer(1.0).timeout
			await LaunchMissiles()
			await get_tree().create_timer(1.0).timeout
			$module.play("close")
		missile_cooldown -= 1.0 * delta
		if missile_cooldown < 0.0:
			missile_cooldown = 0.0
			
		if is_hit:
			$face.material.set_shader_parameter("is_hit", true)
			hit_timer += 1.0 * delta
			if hit_timer > hit_timer_length:
				is_hit = false
				hit_timer = 0.0
				$face.material.set_shader_parameter("is_hit", false)
			
func LaunchMissiles() -> void:
	var snakes: Array = []
	for snake in get_tree().get_nodes_in_group("snakes"):
		if snake.state != Snake.SnakeState.DEAD:
			snakes.append(snake)
	if snakes.size() > 0:
		for i in range($module.get_child_count()):
			$missile_sfx.play()
			var spawn = $module.get_child(i)
			var missile_instance = missile_scene.instantiate()
			map.add_child(missile_instance)
			if i < 3:
				missile_instance.start_left = true
			missile_instance.start(spawn.global_position, snakes.pick_random())
			await get_tree().create_timer(0.2).timeout

func hit(emitter, damage: int) -> void:
	if hp >= 1:
		hp -= damage
		if hp <= 0:
			for i in range(4):
				Input.start_joy_vibration(i, 1.0, 1.0, 7.0)
			boss_hp_bar.visible = false
			$turret.get_node("anchor").hit(self, 999)
			$turret2.get_node("anchor").hit(self, 999)
			$anim_player.play("dying", -1, 1.5)
			$explosion.emitting = true
			$grenade_sfx.stream = multi_explosion_sfx
			$grenade_sfx.play()
			$engine_sfx.stop()
			await get_tree().create_timer(5.0).timeout
			$whiteout.get_node("anim_player").play("expand")
			await get_tree().create_timer(0.6).timeout
			$missile_sfx.stream = whiteout_sfx
			$missile_sfx.play()
			await $whiteout.get_node("anim_player").animation_finished
			$grenade_sfx.stop()
			get_tree().root.get_node("main/music").stop()
			await get_tree().create_timer(4.0).timeout
			# NOTE: Trigger next level
			$defeat_trigger._body_entered(null)
		is_hit = true
