extends CharacterBody2D

var tyler_type: String
var max_health: int = 2
var health: int = max_health
var speed: int = 75
var intelligence: int = 1
var strength: int = 1
var strength_mod: float = .20
var max_think_time : float = 5
var elm_type = "NONE"
var possible_elm_types = ["FIRE", "WATER", "GRASS"]
var current_state
var destination : Vector2
var default_z_index = 0

var cursed : bool = false
var smart : bool = false
var buff : bool = false
var tank : bool = false

var fire_material = load("res://tylermon/fire.tres")
var fire_text = load("res://tylermon/background/flame_text.png")
var water_material = load("res://tylermon/water.tres")
var water_text = load("res://tylermon/background/water_text.png")
var grass_material = load("res://tylermon/grass.tres")
var grass_text = load("res://tylermon/background/grass_text.png")

@export var custom_color : Color

signal knocked_out

enum State {
	WALK_RANDOM, BASIC_ATTACK, IDLE,
 	SPECIAL_ATTACK, KNOCKED_OUT, TARGET_AND_GO, TARGET_AND_ATTACK, TARGET_AND_SPECIAL, BLOCK, CHARGE_UP
	}

var state_weights = [
	{"state": State.IDLE, "roll_weight": 15, "acc_weight": 0, "mult": 1}, 
	{"state": State.WALK_RANDOM, "roll_weight": 10, "acc_weight": 0, "mult": 1}, 
	{"state": State.BASIC_ATTACK, "roll_weight": 7, "acc_weight": 0, "mult": 1},
	{"state": State.TARGET_AND_GO, "roll_weight": 7, "acc_weight": 0, "mult": 1.05},
	{"state": State.BLOCK, "roll_weight": 4, "acc_weight": 0, "mult": 1.15},
	{"state": State.CHARGE_UP, "roll_weight": 3, "acc_weight": 0, "mult": 1.10},
	{"state": State.TARGET_AND_ATTACK, "roll_weight": 2, "acc_weight": 0, "mult": 1.20},
	{"state": State.TARGET_AND_SPECIAL, "roll_weight": 2, "acc_weight": 0, "mult": 1.20},
]
  
@onready var timer = $timer
@onready var attack_timer = $attack_timer
@onready var charge_timer = $charge_timer
@onready var block_timer = $block_timer

@onready var hp_bar = $hp_bar
@onready var health_label = $hp_bar/hp_container/current_health
@onready var max_health_label = $hp_bar/hp_container/max_health
@onready var hurt_box = $scalable_nodes/hurt_box
@onready var basic_atk_box = $scalable_nodes/basic_atk_box
@onready var special_atk_box = $scalable_nodes/special_atk_box
@onready var fight_pos = position
@onready var upgrade_pos = Vector2(position.x + 180, position.y - 20)
@onready var phrase = $phrase
@onready var damage_label = $damage_taken
@onready var sprite = $scalable_nodes/sprite

@onready var anim_player = $modulate_anim
@onready var damage_anim_player = $damage_anim
@onready var element_player = $scalable_nodes/element
@onready var audio_player = $audio_player

@onready var hat = $scalable_nodes/witch_hat
@onready var glasses = $scalable_nodes/glasses
@onready var hair = $scalable_nodes/hair

var cursed_phrases = [
	"fuck", "shit", "Fuckin' Fuck", "asshole", "Get fucked", "fuck you", 
	"fuck this", "fuck tyler", "Bastards", "Motherfucker", "jesus christ", "dickheads", 
	"pigfuckers", "cocksuckers", "kitchen garbage", "shit guzzlers", "wankers", "ass clowns", 
	"dumb shits", "fucking hell", "fuuuck", "douche pickle", "shittertons", "dingle berries", 
	"dipshits", "shmucks"
	]

var happy_sounds = [
	"res://tylermon/sfx/happy_0.wav", "res://tylermon/sfx/happy_01.wav",
	"res://tylermon/sfx/happy_02.wav", "res://tylermon/sfx/happy_03.wav",
	"res://tylermon/sfx/happy_04.wav", "res://tylermon/sfx/happy_05.wav",
	"res://tylermon/sfx/happy_06.wav", "res://tylermon/sfx/happy_08.wav",
	"res://tylermon/sfx/happy_09.wav", "res://tylermon/sfx/happy_10.wav",
	"res://tylermon/sfx/happy_11.wav", "res://tylermon/sfx/happy_12.wav",
	"res://tylermon/sfx/happy_13.wav", "res://tylermon/sfx/happy_14.wav",
	"res://tylermon/sfx/happy_15.wav", "res://tylermon/sfx/happy_16.wav"
	]

var hurt_sounds = [
	"res://tylermon/sfx/hurt_1.wav", "res://tylermon/sfx/hurt_2.wav",
	"res://tylermon/sfx/hurt_0.wav", "res://tylermon/sfx/hurt_3.wav",
	"res://tylermon/sfx/hurt_4.wav", "res://tylermon/sfx/hurt_5.wav"
	]

var death_sounds = [
	"res://tylermon/sfx/death.wav", "res://tylermon/sfx/death_2.wav", 
	"res://tylermon/sfx/death_3.wav"
	]

var special_sound = ["res://tylermon/sfx/punch.wav"]
var basic_attack_sound = ["res://tylermon/sfx/spike.wav"]
var charge_sound = ["res://tylermon/sfx/charge.wav"]
var block_sound = ["res://tylermon/sfx/block.wav"]

func _ready():
	phrase.text = ""
	set_state(State.IDLE)
	set_starting_element()
	toggle_particle(true)
	sprite.modulate = custom_color
	get_parent().get_parent().connect("upgraded", upgrade_react)
	get_parent().get_parent().connect("set_element", show_element_effect)
	

func _physics_process(delta):
	if health <= 0 and current_state != State.KNOCKED_OUT:
		set_state(State.KNOCKED_OUT)
	move_and_slide()
	update_state(current_state, delta)
	if !anim_player.is_playing():
		sprite.modulate = custom_color


func _on_timer_timeout():
	var total_weight = 0.0
	for state in state_weights:
		total_weight += state.roll_weight + (intelligence * state.mult)
		state.acc_weight = total_weight
	var random_number = randf_range(0.0, total_weight)
	for state in state_weights:
		if state.acc_weight > random_number:
			set_state(state.state)
			break
	var random_wait_time = randf_range(1, max_think_time - (intelligence * .25))
	if random_wait_time <= 0:
		random_wait_time = 1
	timer.start(random_wait_time)


func set_state(state):
	match state:
		State.WALK_RANDOM:
			play_anims("move")
			chance_to_say_phrase(cursed_phrases, 4)
			destination = Vector2(randi_range(100,1000), randi_range(100, 500))
		
		State.BASIC_ATTACK:
			timer.paused = true
			velocity = Vector2()
			chance_to_say_phrase(cursed_phrases, 4)
			z_index = default_z_index + 1
			play_anims("basic_atk")
			play_audio(basic_attack_sound)
			var basic_attack = basic_atk_box.get_children()
			for hitbox in basic_attack:
				hitbox.disabled = false
			attack_timer.start(.2)
		
		State.CHARGE_UP:
			chance_to_say_phrase(cursed_phrases, 4)
			timer.paused = true
			velocity = Vector2()
			play_anims("charge")
			play_audio(charge_sound)
			charge_timer.start(2)
			z_index = default_z_index + 1
		
		State.SPECIAL_ATTACK:
			timer.paused = true
			velocity = Vector2()
			chance_to_say_phrase(cursed_phrases, 4)
			z_index = default_z_index + 1
			play_anims("special_atk")
			play_audio(special_sound)
			var special_attack = special_atk_box.get_children()
			for hitbox in special_attack:
				hitbox.disabled = false
			attack_timer.start(.2)
		
		State.IDLE:
			audio_player.stop()
			chance_to_say_phrase(cursed_phrases, 4)
			play_anims("idle")
			velocity = Vector2()
		
		State.KNOCKED_OUT:
			toggle_particle(false)
			_on_block_timer_timeout()
			_on_attack_timer_timeout()
			hurt_box.get_child(0).disabled = true
			play_audio(death_sounds)
			chance_to_say_phrase(cursed_phrases, 1)
			play_anims("knocked_out")
			timer.stop()
			z_index = default_z_index - 2
			get_node("collision").disabled = true
			health_label.text = str(health)
			hp_bar.value = health
			hp_bar.visible = false
			velocity = Vector2()
			var victory_points = check_how_many_other_mons_knocked_out()
			var player = get_parent()
			player.wins += victory_points
			$dead_anim_timer.start(.60)
			$knockout_timer.start(1.25)

		State.TARGET_AND_GO:
			play_anims("move")
			chance_to_say_phrase(cursed_phrases, 4)
			var random_mon = get_other_random_mon()
			if random_mon == null:
				audio_player.stop()
				play_anims("idle")
			else:
				destination = random_mon.position
		
		State.TARGET_AND_ATTACK:
			play_anims("move")
			chance_to_say_phrase(cursed_phrases, 4)
			var random_mon = get_other_random_mon()
			if random_mon == null:
				audio_player.stop()
				play_anims("idle")
			else:
				destination = random_mon.position

		State.TARGET_AND_SPECIAL:
			play_anims("move")
			chance_to_say_phrase(cursed_phrases, 4)
			var random_mon = get_other_random_mon()
			if random_mon == null:
				audio_player.stop()
				play_anims("idle")
			else:
				destination = random_mon.position
		
		State.BLOCK:
			chance_to_say_phrase(cursed_phrases, 4)
			play_audio(block_sound)
			velocity = Vector2()
			block_timer.start(2)
			play_anims("block")
			timer.paused = true
			z_index = default_z_index + 1
			hurt_box.get_child(0).disabled = true
	
	current_state = state


func update_state(state, delta):
	match state:
		State.IDLE:
			pass

		State.WALK_RANDOM:
			move_to_destination(delta)

		State.TARGET_AND_GO:
			move_to_destination(delta)
		
		State.TARGET_AND_ATTACK:
			move_to_destination(delta)
			if position.distance_to(destination) < 150:
				set_state(State.BASIC_ATTACK)

		State.TARGET_AND_SPECIAL:
			move_to_destination(delta)
			if position.distance_to(destination) < 200:
				set_state(State.CHARGE_UP)

		State.BLOCK:
			pass
		
		State.CHARGE_UP:
			pass
			
		State.BASIC_ATTACK:
			pass

		State.SPECIAL_ATTACK:
			pass
	
		State.KNOCKED_OUT:
			pass


func get_other_random_mon():
	var get_all_mons = get_tree().get_nodes_in_group("mons")
	var mons_to_target = []
	var random_mon
	for mon in get_all_mons:
		if mon == self or mon.current_state == State.KNOCKED_OUT:
			continue
		mons_to_target.append(mon)
	if mons_to_target.size() > 0:
		random_mon = mons_to_target.pick_random()
		return random_mon
	else:
		return null


func check_how_many_other_mons_knocked_out():
	var all_mons = get_tree().get_nodes_in_group("mons")
	var counter = 0
	for mon in all_mons:
		if mon.current_state == State.KNOCKED_OUT and mon != self:
			counter += 1
	if counter == 0:
		return 0
	if counter == 1:
		return 1
	if counter == 2:
		return 3
	else:
		return 5


func _on_hurt_box_area_entered(area):
	if area == basic_atk_box or area == special_atk_box : return
	var attackers = hurt_box.get_overlapping_areas()
	for attack in attackers:
		var attacking_mon = attack.get_parent().get_parent()
		if elm_type == "WATER" && attacking_mon.elm_type == "GRASS" or elm_type == "FIRE" && attacking_mon.elm_type == "WATER" or elm_type == "GRASS" && attacking_mon.elm_type == "FIRE" or elm_type == "NONE" && attacking_mon.elm_type != "NONE":
			damage(attacking_mon, 1.50, "super")
		elif elm_type == "WATER" && attacking_mon.elm_type == "FIRE" or elm_type == "FIRE" && attacking_mon.elm_type == "GRASS"  or elm_type == "GRASS" && attacking_mon.elm_type == "WATER":
			damage(attacking_mon, .85, "not")
		else:
			damage(attacking_mon, 1, null)
	health_label.text = str(health)
	hp_bar.value = health
	velocity = Vector2()
	play_audio(hurt_sounds)
	anim_player.play("hurt")
	play_anims("hurt")
	if health <= roundi(max_health * .25):
		hp_bar.get_theme_stylebox("fill").bg_color = Color(1, 0.337, 0.333)


func damage(mon, modifier: float, effect):
	var damage = mon.strength * .40
	damage *= modifier
	if mon.current_state == State.SPECIAL_ATTACK:
		damage += (mon.strength * .30)
	if damage <= 1:
		damage = 1
	damage = round(damage)
	if effect == "super":
		damage_label.set("theme_override_colors/font_color", "ea4440")
		damage_label.text = str(damage) + "!"
	elif effect == "not":
		damage_label.set("theme_override_colors/font_color", "000000")
		damage_label.text = str(damage) + "<"
	elif effect == null:
		damage_label.set("theme_override_colors/font_color", "ffffff")
		damage_label.text = str(damage)	
	damage_anim_player.play("damage_amount")
	health -= damage


func chance_to_say_phrase(array, chance : int):
	var rand_num = randi_range(1,chance)
	if cursed && rand_num == 1:
		var rand_phrase = cursed_phrases.pick_random()
		phrase.get_node("phrase_timer").start(3)
		phrase.text = rand_phrase
		await phrase.get_node("phrase_timer").timeout
		phrase.text = ""

func switch_round_modes(fight_time):
	if fight_time:
		timer.start(.5)
		z_index = default_z_index
		position = fight_pos
		hp_bar.visible = true
		special_atk_box.get_child(0).disabled = true
		var basic_attack = basic_atk_box.get_children()
		for hitbox in basic_attack:
			hitbox.disabled = true
		hurt_box.get_child(0).disabled = false
		get_node("collision").disabled = false
		health = max_health
		hp_bar.max_value = max_health
		hp_bar.value = max_health
		max_health_label.text = str(max_health)
		health_label.text = str(max_health)
		timer.paused = false
	else:
		get_node("collision").disabled = true
		toggle_particle(true)
		set_state(State.IDLE)
		timer.stop()
		hp_bar.visible = true
		play_anims("upgrade_idle")
		health = max_health
		health_label.text = str(max_health)
		hp_bar.max_value = max_health
		hp_bar.value = max_health
		hp_bar.get_theme_stylebox("fill").bg_color = Color(0, 0.727, 0.147)
		velocity = Vector2()
		position = upgrade_pos


func pause():
	velocity = Vector2()
	_on_attack_timer_timeout()
	timer.stop()


func move_to_destination(delta):
	if position.x <= destination.x :
		sprite.flip_h = false
		hat.flip_h = false
		glasses.flip_h = false
		hair.flip_h = false
	else:
		sprite.flip_h = true
		hat.flip_h = true
		glasses.flip_h = true
		hair.flip_h = true
	if !timer.is_stopped():
		position = position.move_toward(destination, speed * delta)


func _on_attack_timer_timeout():
	timer.paused = false
	var basic_attack = basic_atk_box.get_children()
	for hitbox in basic_attack:
		hitbox.disabled = true
	var special_attack = special_atk_box.get_children()
	for hitbox in special_attack:
		hitbox.disabled = true
	z_index = default_z_index


func _on_block_timer_timeout():
	timer.paused = false
	hurt_box.get_child(0).disabled = false
	z_index = default_z_index


func _on_charge_timer_timeout():
	if current_state == State.IDLE or current_state == State.KNOCKED_OUT:
		return
	else:
		set_state(State.SPECIAL_ATTACK)


func upgrade_react(reaction):
	if reaction == "good":
		play_anims("upgrade_good")
		play_audio(happy_sounds)
	if reaction == "bad":
		play_anims("upgrade_bad")
		play_audio(hurt_sounds)


func show_element_effect(element: String):
	if element == "FIRE":
		elm_type = "FIRE"
		element_player.texture = fire_text
		element_player.process_material = fire_material
		element_player.emitting = true
	if element == "WATER":
		elm_type = "WATER"
		element_player.texture = water_text
		element_player.process_material = water_material
		element_player.emitting = true
	if element == "GRASS":
		elm_type = "GRASS"
		element_player.texture = grass_text
		element_player.process_material = grass_material
		element_player.emitting = true


func toggle_particle(effect : bool):
	if effect == true and elm_type != "NONE":
		element_player.emitting = true
	if effect == false and elm_type != "NONE":
		element_player.emitting = false


func _on_knockout_timer_timeout():
	emit_signal("knocked_out")


func _on_dead_anim_timer_timeout():
	play_anims("dead")


func play_audio(arr):
	var audio = load(arr.pick_random())
	audio_player.stream = audio
	audio_player.play()


func set_starting_element():
	elm_type = possible_elm_types.pick_random()
	show_element_effect(elm_type)


func play_anims(anim_name):
	sprite.play(anim_name)
	hat.play(anim_name)
	glasses.play(anim_name)
	hair.play(anim_name)
