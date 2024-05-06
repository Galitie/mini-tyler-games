extends CharacterBody2D

var tyler_type: String
var max_health: int = 2
var health: int = max_health
var speed: int = 75
var intelligence: int = 1
var strength: int = 1
var strength_mod: float = .20
var elm_type = "NONE"
var current_state = State.IDLE
var destination : Vector2
var default_z_index = 0
var current_player_command = State.TARGET_AND_ATTACK
var cursed : bool = false
var max_think_time : float = 3

@export var custom_color : Color

signal knocked_out(place)

enum State {
	WALK_RANDOM, BASIC_ATTACK, IDLE,
 	SPECIAL_ATTACK, KNOCKED_OUT, TARGET_AND_GO,
	PLAYER_COMMAND, TARGET_AND_ATTACK, TARGET_AND_SPECIAL, BLOCK, CHARGE_UP
	}


var state_weights = [
	{"state": State.IDLE, "roll_weight": 15, "acc_weight": 0, "mult": 1}, 
	{"state": State.WALK_RANDOM, "roll_weight": 10, "acc_weight": 0, "mult": 1}, 
	{"state": State.BASIC_ATTACK, "roll_weight": 7, "acc_weight": 0, "mult": 1},
	{"state": State.TARGET_AND_GO, "roll_weight": 7, "acc_weight": 0, "mult": 1.05},
	{"state": State.BLOCK, "roll_weight": 4, "acc_weight": 0, "mult": 1.10},
	{"state": State.CHARGE_UP, "roll_weight": 4, "acc_weight": 0, "mult": 1.10},
	{"state": State.TARGET_AND_ATTACK, "roll_weight": 2, "acc_weight": 0, "mult": 1.20},
	{"state": State.TARGET_AND_SPECIAL, "roll_weight": 2, "acc_weight": 0, "mult": 1.20},
	{"state": State.PLAYER_COMMAND, "roll_weight": 1, "acc_weight": 0, "mult": 7}
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


#var bored_phrases = ["Whatever", "ZZZ", "Meh", "IDK", "*shrugs*", "???", "I'm bored"]
#var target_phrases = ["Charge!", "For Frodo!", "Liberty or Death!", "Leeeroy Jenkins!", "I have the power!"]
#var attack_phrases = ["DIE!", "Justice!", "HI-YAH!", "Take that!", "I need the last hit"]
#var hurt_phrases = ["Ouch!", "YEOW!", "!", "I need help!", "Don't touch me!", ">:(", "Ow!", "How dare!", "Oof!", "Good grief!", "Jeez!", "Eep!", "Yikes!", "Zoinks!", "argh!"]
var knocked_out_phrases = ["Avenge me!", "X.X", "RIP", ":(", "T.T", "RIPAROONIE", "Alas...", "Think of me", "dang it", "c'mon!", "aw nuts", "D'oh!", "Rats!"]
#var listening_phrases = ["Aye-aye!", "I'm on it!", "Roger roger", "I'm all ears", "No problem", "Understood", "Acknowledged", "Yes master", "say no more", "You bet!", "Loud and clear!"]
#var blocking_phrases = ["Not this time!", "Not today!", "NOPE", "Get back!", "Can't touch this"]
var cursed_phrases = ["fuck", "shit", "Fuckin' Fuck", "asshole", "Get fucked", "fuck you", "fuck this", "fuck tyler", "Bastards", "Motherfucker", "jesus christ", "dickheads", "pigfuckers", "cocksuckers", "kitchen garbage", "shit guzzlers", "wankers", "ass clowns", "dumb shits", "fucking hell", "fuuuck"]

func _ready():
	phrase.text = ""
	#get_parent().connect("send_command", get_command)
	sprite.modulate = custom_color
	get_parent().get_parent().connect("upgraded", upgrade_react)


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
	var random_wait_time = randf_range(1,max_think_time)
	timer.start(random_wait_time)


func set_state(state):
	match state:
		State.WALK_RANDOM:
			sprite.play("move")
			#chance_to_say_phrase(bored_phrases, 3)
			destination = Vector2(randi_range(100,1000), randi_range(100, 500))
		
		State.BASIC_ATTACK:
			timer.paused = true
			velocity = Vector2()
			#chance_to_say_phrase(attack_phrases, 4)
			z_index = default_z_index + 1
			sprite.play("basic_atk")
			basic_atk_box.get_child(0).disabled = false
			attack_timer.start(.2)
		
		State.CHARGE_UP:
			timer.paused = true
			velocity = Vector2()
			sprite.play("charge")
			charge_timer.start(2)
			z_index = default_z_index + 1
		
		State.SPECIAL_ATTACK:
			timer.paused = true
			velocity = Vector2()
			#chance_to_say_phrase(attack_phrases, 4)
			z_index = default_z_index + 1
			sprite.play("special_atk")
			var special_attack = special_atk_box.get_children()
			for hitbox in special_attack:
				hitbox.disabled = false
			attack_timer.start(.2)
		
		State.IDLE:
			sprite.play("idle")
			velocity = Vector2()
		
		State.KNOCKED_OUT:
			current_state = State.KNOCKED_OUT
			sprite.play("just_knocked_out")
			chance_to_say_phrase(knocked_out_phrases, 1)
			timer.paused = true
			z_index = default_z_index - 1
			get_node("collision").disabled = true
			hurt_box.get_child(0).disabled = true
			health_label.text = str(health)
			hp_bar.value = health
			hp_bar.visible = false
			velocity = Vector2()
			var victory_points = check_how_many_other_mons_knocked_out()
			var player = get_parent()
			player.wins += victory_points
			emit_signal("knocked_out")

		State.TARGET_AND_GO:
			sprite.play("move")
			#chance_to_say_phrase(target_phrases, 4)
			destination = get_other_random_mon().position
		
		State.TARGET_AND_ATTACK:
			sprite.play("move")
			#chance_to_say_phrase(target_phrases, 4)
			destination = get_other_random_mon().position

		State.TARGET_AND_SPECIAL:
			sprite.play("move")
			#chance_to_say_phrase(target_phrases, 4)
			destination = get_other_random_mon().position
		
		State.BLOCK:
			#chance_to_say_phrase(blocking_phrases, 4)
			velocity = Vector2()
			block_timer.start(2)
			sprite.play("block")
			timer.paused = true
			z_index = default_z_index + 1
			hurt_box.get_child(0).disabled = true

		State.PLAYER_COMMAND:
			#chance_to_say_phrase(listening_phrases, 1)
			set_state(current_player_command)
			
	if state == State.PLAYER_COMMAND:
		current_state = current_player_command
	else:
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
			when_done_play_next_animation()


func get_other_random_mon():
	var get_all_mons = get_tree().get_nodes_in_group("mons")
	var random_mon = get_all_mons.pick_random()
	while random_mon == self or random_mon.current_state == State.KNOCKED_OUT:
		random_mon = get_all_mons.pick_random()
	return random_mon


func check_how_many_other_mons_knocked_out():
	var all_mons = get_tree().get_nodes_in_group("mons")
	var counter = 0
	for mon in all_mons:
		if mon.current_state == State.KNOCKED_OUT:
			if mon.name != name:
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
	#chance_to_say_phrase(hurt_phrases, 2)
	var attackers = hurt_box.get_overlapping_areas()
	for attack in attackers:
		var attacking_mon = attack.get_parent().get_parent()
		if elm_type == "WATER" && attacking_mon.elm_type == "GRASS" or elm_type == "FIRE" && attacking_mon.elm_type == "WATER" or elm_type == "GRASS" && attacking_mon.elm_type == "FIRE":
			damage(attacking_mon, 1, "super")
		elif elm_type == "WATER" && attacking_mon.elm_type == "FIRE" or elm_type == "FIRE" && attacking_mon.elm_type == "GRASS"  or elm_type == "GRASS" && attacking_mon.elm_type == "WATER":
			damage(attacking_mon, -1, "not")
		elif elm_type == "NONE" && attacking_mon.elm_type != "NONE":
			damage(attacking_mon, .50, null)
		else:
			damage(attacking_mon, 0, null)
	health_label.text = str(health)
	hp_bar.value = health
	velocity = Vector2()
	anim_player.play("hurt")
	sprite.play("hurt")
	if health <= roundi(max_health * .25):
		hp_bar.get_theme_stylebox("fill").bg_color = Color(1, 0.337, 0.333)


func damage(mon, modifier: int, effect):
	var damage = mon.strength * .65
	damage = damage + (modifier * .65)
	if mon.current_state == State.SPECIAL_ATTACK:
		damage += (mon.strength * .15)
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
	if cursed:
		var rand_phrase = cursed_phrases.pick_random()
		phrase.get_node("phrase_timer").start(2)
		phrase.text = rand_phrase
		await phrase.get_node("phrase_timer").timeout
		phrase.text = ""
	else:
		if rand_num == 1:
			var rand_phrase = array.pick_random()
			phrase.get_node("phrase_timer").start(2)
			phrase.text = rand_phrase
			await phrase.get_node("phrase_timer").timeout
			phrase.text = ""


func command_thought(action):
	if action == State.BLOCK:
		$thought.text = "Block"
	if action == State.CHARGE_UP:
		$thought.text = "Special"
	if action == State.BASIC_ATTACK:
		$thought.text = "Attack"
	if action == State.TARGET_AND_GO:
		$thought.text = "Target & go"
	if current_state != State.KNOCKED_OUT:
		$thought_anim.play("thought")


func switch_round_modes(fight_time):
	if fight_time:
		timer.start(.5)
		position = fight_pos
		hp_bar.visible = true
		basic_atk_box.get_child(0).disabled = true
		var special_attack = special_atk_box.get_children()
		for hitbox in special_attack:
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
		set_state(State.IDLE)
		timer.stop()
		hp_bar.visible = true
		sprite.play("upgrade_idle")
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
	_on_block_timer_timeout()
	timer.stop()


func move_to_destination(delta):
	if position.x <= destination.x :
		sprite.flip_h = false
	else:
		sprite.flip_h = true
	if !timer.is_stopped():
		position = position.move_toward(destination, speed * delta)


#func get_command(command, player_index):
	#var player = get_parent().name
	#if player.split("player")[1] == str(player_index):
		#print("mon", player_index + 1, " recieved command ", State.keys()[command])
		#current_player_command = command
	#command_thought(command)


func _on_attack_timer_timeout():
	timer.paused = false
	basic_atk_box.get_child(0).disabled = true
	var special_attack = special_atk_box.get_children()
	for hitbox in special_attack:
		hitbox.disabled = true
	z_index = default_z_index


func _on_block_timer_timeout():
	timer.paused = false
	hurt_box.get_child(0).disabled = false
	z_index = default_z_index


func _on_charge_timer_timeout():
	z_index = default_z_index
	if current_state == State.IDLE or current_state == State.KNOCKED_OUT:
		return
	else:
		set_state(State.SPECIAL_ATTACK)


func when_done_play_next_animation():
	if !sprite.is_playing():
		sprite.play("dead")	


func upgrade_react(reaction):
	if reaction == "good":
		sprite.play("upgrade_react_good")
	if reaction == "bad":
		sprite.play("upgrade_react_bad")
