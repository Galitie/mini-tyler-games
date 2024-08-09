extends CharacterBody2D

const MAX_HP: int = 2
var hp: int = MAX_HP

var hiding_spots: Array = [
	Vector2(-104, -72),
	Vector2(-136, 104),
	Vector2(8, 168),
	Vector2(136, 152),
	Vector2(136, 40),
	Vector2(88, -56)
]

var mine_scene = preload("res://epsilon/mine.tscn")

var run_speed: float = 60

var direction: String = "d"
var dead: bool = false

var is_hit: bool = false
var hit_timer: float = 0.0
var hit_timer_length: float = 0.1

var hit_cycle: bool = false

var placing_mine: bool = false

@onready var boss_hp_bar = get_parent().get_parent().get_parent().get_node("camera/ui/camera_space/boss_life")
@onready var boss_hp = boss_hp_bar.get_node("hp")

@onready var map = get_parent().get_parent()

@onready var rng = RandomNumberGenerator.new()

var opening_line = preload("res://epsilon/vo/rich_man2man.mp3")

var voicelines: Array = [
	preload("res://epsilon/vo/rich_reload.mp3"),
	preload("res://epsilon/vo/rich_alive.mp3"),
	preload("res://epsilon/vo/rich_feelofbattle.mp3"),
	preload("res://epsilon/vo/rich_hand2hand.mp3"),
	preload("res://epsilon/vo/rich_hurtme.mp3"),
	preload("res://epsilon/vo/rich_kuwabara.mp3"),
	preload("res://epsilon/vo/rich_love.mp3"),
	preload("res://epsilon/vo/rich_memorycard.mp3"),
	preload("res://epsilon/vo/rich_pain.mp3"),
	preload("res://epsilon/vo/rich_prettygood.mp3"),
	preload("res://epsilon/vo/rich_punch.mp3"),
]

var voiceline_rotation = voicelines.duplicate(true)

var vo_queue: Array = []

var dead_line = preload("res://epsilon/vo/rich_dead.mp3")

var can_speak: bool = false

@onready var vo_text = map.get_parent().get_node("camera/ui/camera_space/text_container/text")

func _ready() -> void:
	add_to_group("entities")
	
	boss_hp_bar.visible = true
	boss_hp.size.x = float((float(hp) / float(MAX_HP)) * 77.0)
	
	# NOTE: To sync navigation agent with server
	set_physics_process(false)
	call_deferred("agent_setup")
	
	$sprite.animation_finished.connect(_animation_finished)
	$timer.timeout.connect(_timeout)
	$vo_timer.timeout.connect(_vo_timeout)
	
func agent_setup() -> void:
	# NOTE: HA HA SPAGHET
	await get_tree().physics_frame
	await get_tree().physics_frame
	set_physics_process(true)
	
	for snake in get_tree().get_nodes_in_group("snakes"):
		snake.pistol_ammo = 0
		snake.stinger_ammo = 0
		snake.grenade_ammo = 0
	
	$nav_agent.target_position = global_position
	$sfx.stream = opening_line
	$sfx.play()
	$timer.start()
	vo_text.text = "[center]Enough, Snake![/center]"
	await get_tree().create_timer(1.9).timeout
	vo_text.text = "[center]Let us fight.[/center]"
	await get_tree().create_timer(1.6).timeout
	vo_text.text = "[center]Man to...men.[/center]"
	await $sfx.finished
	vo_text.text = ""
	
	$vo_timer.start()
	
func _physics_process(delta: float) -> void:
	boss_hp.size.x = move_toward(boss_hp.size.x, float((float(hp) / float(MAX_HP)) * 77.0), 20.0 * delta)
	
	if is_hit:
			$sprite.material.set_shader_parameter("is_hit", true)
			hit_timer += 1.0 * delta
			if hit_timer > hit_timer_length:
				is_hit = false
				hit_timer = 0.0
				$sprite.material.set_shader_parameter("is_hit", false)
	
	if !dead:
		if !placing_mine:
			if !$nav_agent.is_target_reached():
				var t_direction = to_local($nav_agent.get_next_path_position()).normalized()
				direction = GetDirection(t_direction)
				if direction.ends_with("l"):
					$sprite.flip_h = true
				else:
					$sprite.flip_h = false
				$sprite.play("run" + "_" + direction, 1.3)
				global_position += t_direction * run_speed * delta
				
				var mine_chance = rng.randi_range(0, 100)
				if mine_chance > 99:
					placing_mine = true
					$sprite.play("place_mine", 2.0)
			else:
				$sprite.play("idle_d")
				if $timer.is_stopped():
					$timer.start()

func hit(emitter, damage: int) -> void:
	if hp > 0:
		hp -= damage
		is_hit = true
		if hp <= 0:
			hp = 0
			dead = true
			$sprite.play("fall_d")
			$shadow.visible = false
			$timer.stop()
			$vo_timer.stop()
			$sfx.bus = "Reverb"
			$sfx.stop()
			$sfx.stream = dead_line
			$sfx.play()
			vo_text.text = "[center]Augh...![/center]"
			await get_tree().create_timer(1.3).timeout
			vo_text.text = "[center]...My...[/center]"
			await get_tree().create_timer(1.1).timeout
			vo_text.text = "[center]...parking...spots...![/center]"
			await $sfx.finished
			vo_text.text = ""
			return

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
	
func _timeout() -> void:
	var next_spots = hiding_spots.duplicate(true)
	next_spots.erase($nav_agent.target_position)
	$nav_agent.target_position = next_spots.pick_random()
	can_speak = true
	
func _vo_timeout() -> void:
	if voiceline_rotation.size() == 0:
		voiceline_rotation = voicelines.duplicate(true)
	$sfx.stream = voiceline_rotation.pick_random()
	$sfx.play()
	
	# NOTE: Oh boy, here we go...
	var voiceline_index = voicelines.find($sfx.stream)
	match voiceline_index:
		0:
			vo_text.text = "[center]I love to reload during a battle![/center]"
			await $sfx.finished
			vo_text.text = ""
		1:
			vo_text.text = "[center]Alright.[/center]"
			await get_tree().create_timer(1.1).timeout
			vo_text.text = "[center]I'm alive again![/center]"
			await $sfx.finished
			vo_text.text = ""
		2:
			vo_text.text = "[center]Do you remember, Snake?[/center]"
			await get_tree().create_timer(2.1).timeout
			vo_text.text = "[center]The feel of battle?[/center]"
			await $sfx.finished
			vo_text.text = ""
		3:
			vo_text.text = "[center]Hand to hand![/center]"
			await get_tree().create_timer(1.3).timeout
			vo_text.text = "[center]It's the basis of all combat...[/center]"
			await get_tree().create_timer(1.7).timeout
			vo_text.text = "[center]...Only a fool trusts his life to a weapon![/center]"
			await $sfx.finished
			vo_text.text = ""
		4:
			vo_text.text = "[center]Hurt me more![/center]"
			await $sfx.finished
			vo_text.text = ""
		5:
			vo_text.text = "[center]Kuwabara! Kuwabara![/center]"
			await $sfx.finished
			vo_text.text = ""
		6:
			vo_text.text = "[center]Snake...[/center]"
			await get_tree().create_timer(1.5).timeout
			vo_text.text = "[center]Do you think...?[/center]"
			await get_tree().create_timer(1.35).timeout
			vo_text.text = "[center]...Love can bloom on a battlefield?[/center]"
			await $sfx.finished
			vo_text.text = ""
		7:
			vo_text.text = "[center]Ah...I can see into your mind![/center]"
			await get_tree().create_timer(4.3).timeout
			vo_text.text = "[center]So you like to play DARK SOULS?[/center]"
			await get_tree().create_timer(3.2).timeout
			vo_text.text = "[center]...What a shit game![/center]"
			await $sfx.finished
			vo_text.text = ""
		8:
			vo_text.text = "[center]...I've been waiting for this pain![/center]"
			await $sfx.finished
			vo_text.text = ""
		9:
			vo_text.text = "[center]Hah![/center]"
			await get_tree().create_timer(0.75).timeout
			vo_text.text = "[center]You're pretty good![/center]"
			await $sfx.finished
			vo_text.text = ""
		10:
			vo_text.text = "[center]That's it![/center]"
			await get_tree().create_timer(1.4).timeout
			vo_text.text = "[center]I remember.[/center]"
			await get_tree().create_timer(1.2).timeout
			vo_text.text = "[center]That punch![/center]"
			await $sfx.finished
			vo_text.text = ""
	
	voiceline_rotation.erase($sfx.stream)
	$vo_timer.start()

func _animation_finished() -> void:
	if placing_mine:
		var mine_instance = mine_scene.instantiate()
		mine_instance.global_position = global_position
		map.add_child(mine_instance)
		placing_mine = false
	
	if dead:
		z_index = -1
		await $sfx.finished
		await get_tree().create_timer(3.0).timeout
		get_tree().root.get_node("main").End()
