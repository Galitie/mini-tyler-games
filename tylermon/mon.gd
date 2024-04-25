extends CharacterBody2D

var tyler_type: String
var attacks
var max_health: int = 3
var health: int = max_health
var speed: int = 75
var intelligence: int = 1
var strength: int = 1
var elm_type = "NONE"
var commands
var current_state 
var destination : Vector2
var default_z_index = 0

signal knocked_out

enum State {
	WALK_RANDOM, BASIC_ATTACK, IDLE,
 	SPECIAL_ATTACK, KNOCKED_OUT, TARGET_AND_GO,
	PLAYER_COMMAND, START_FIGHT, UPGRADE, TARGET_AND_ATTACK, TARGET_AND_SPECIAL
	}

var state_weights = [
	{"state": State.IDLE, "roll_weight": 15, "acc_weight": 0, "mult": 1}, 
	{"state": State.WALK_RANDOM, "roll_weight": 10, "acc_weight": 0, "mult": 1}, 
	{"state": State.BASIC_ATTACK, "roll_weight": 7, "acc_weight": 0, "mult": 1},
	{"state": State.TARGET_AND_GO, "roll_weight": 7, "acc_weight": 0, "mult": 1.05},
	{"state": State.SPECIAL_ATTACK, "roll_weight": 3, "acc_weight": 0, "mult": 1.10},
	{"state": State.TARGET_AND_ATTACK, "roll_weight": 1, "acc_weight": 0, "mult": 1.20},
	{"state": State.TARGET_AND_SPECIAL, "roll_weight": 1, "acc_weight": 0, "mult": 1.20},
	{"state": State.PLAYER_COMMAND, "roll_weight": 0, "acc_weight": 0, "mult": 1.25}
]

@onready var anim_player = $anim_player
@onready var timer = $timer
@onready var hp_bar = $hp_bar
@onready var health_label = $hp_bar/hp_container/current_health
@onready var max_health_label = $hp_bar/hp_container/max_health
@onready var hurt_box = $hurt_box
@onready var basic_atk_box = $basic_atk_box
@onready var special_atk_box = $special_atk_box
@onready var fight_pos = position
@onready var upgrade_pos = Vector2(position.x + 80, position.y - 20)
@onready var phrase = $phrase
@onready var attack_timer = $attack_timer
@onready var damage_label = $damage_taken

var bored_phrases = ["Whatever", "ZZZ", "Meh", "IDK", "*shrugs*", "???", "I'm bored"]
var target_phrases = ["Charge!", "For Frodo!", "Liberty or Death!", "Leeeroy Jenkins!", "I have the power!"]
var attack_phrases = ["DIE!", "Not today!", "Justice!", "HI-YAH!", "Take that!", "I need the last hit"]
var hurt_phrases = ["Ouch!", "YEOW!", "!", "I need help!", "Don't touch me!", ">:(", "Ow!", "How dare!", "Oof!", "Good grief!", "Jeez!", "Eep!", "Yikes!", "Zoinks!", "argh!"]
var knocked_out_phrases = ["Avenge me!", "X.X", "RIP", ":(", "T.T", "RIPAROONIE", "Alas...", "Think of me", "dang it", "c'mon!", "aw nuts", "D'oh!", "Rats!"]
var listening_phrases = ["Aye-aye!", "I'm on it!", "Roger roger", "I'm all ears", "No problem", "Understood", "Acknowledged", "Yes master", "say no more", "You bet!", "Loud and clear!"]


func _ready():
	set_state(State.START_FIGHT)
	phrase.text = ""


func _physics_process(delta):
	if health <= 0 and current_state != State.KNOCKED_OUT:
		set_state(State.KNOCKED_OUT)
	move_and_slide()
	update_state(current_state, delta)


func set_state(state):
	match state:
		State.WALK_RANDOM:
			chance_to_say_phrase(bored_phrases, 1)
			destination = Vector2(randi_range(100,1000), randi_range(100, 500))
		
		State.BASIC_ATTACK:
			chance_to_say_phrase(attack_phrases, 1)
			anim_player.play("basic_atk")
			attack_timer.start(.3)
		
		State.SPECIAL_ATTACK:
			chance_to_say_phrase(attack_phrases, 1)
			anim_player.play("special_atk")
			attack_timer.start(.3)
		
		State.IDLE:
			chance_to_say_phrase(bored_phrases, 1)
		
		State.KNOCKED_OUT:
			emit_signal("knocked_out")
			get_node("collision").disabled = true
			hurt_box.get_child(0).disabled = true
			chance_to_say_phrase(knocked_out_phrases, 3)
			z_index = default_z_index - 1
			anim_player.play("knocked_out")
			hp_bar.visible = false

		State.TARGET_AND_GO:
			chance_to_say_phrase(target_phrases, 1)
			destination = get_other_random_mon().position
		
		State.TARGET_AND_ATTACK:
			chance_to_say_phrase(target_phrases, 1)
			destination = get_other_random_mon().position

		State.TARGET_AND_SPECIAL:
			chance_to_say_phrase(target_phrases, 1)
			destination = get_other_random_mon().position

		State.PLAYER_COMMAND:
			chance_to_say_phrase(listening_phrases, 1)

		State.START_FIGHT:
			position = fight_pos
			hp_bar.visible = true
			basic_atk_box.get_child(0).disabled = true
			special_atk_box.get_child(0).disabled = true
			hurt_box.get_child(0).disabled = false
			get_node("collision").disabled = false
			health = max_health
			hp_bar.max_value = max_health
			hp_bar.value = max_health
			max_health_label.text = str(max_health)
			health_label.text = str(max_health)
			timer.paused = false
			timer.start(.5)
		
		State.UPGRADE:
			if current_state == State.KNOCKED_OUT:
				anim_player.play("get_up")
				hp_bar.visible = true
			health = max_health
			health_label.text = str(max_health)
			hp_bar.max_value = max_health
			hp_bar.value = max_health
			#upgrade animation
	current_state = state


func update_state(state, delta):
	match state:
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
				set_state(State.SPECIAL_ATTACK)

		State.UPGRADE:
			timer.paused = true
			position = upgrade_pos
			velocity = Vector2()
			max_health_label.text = str(max_health)
			health_label.text = str(max_health)

		State.BASIC_ATTACK:
			velocity = Vector2()
			attack(basic_atk_box)

		State.SPECIAL_ATTACK:
			velocity = Vector2()
			attack(special_atk_box)

		State.START_FIGHT:
			velocity = Vector2()
			
		State.KNOCKED_OUT:
			velocity = Vector2()
			
		State.PLAYER_COMMAND:
			velocity = Vector2()
			# placeholder


func get_other_random_mon():
	var get_all_mons = get_tree().get_nodes_in_group("mons")
	var random_mon = get_all_mons.pick_random()
	while random_mon == self or random_mon.current_state == State.KNOCKED_OUT:
		random_mon = get_all_mons.pick_random()
	return random_mon


func _on_timer_timeout():
	var total_weight = 0.0
	for state in state_weights:
		total_weight += state.roll_weight + (intelligence * state.mult)
		state.acc_weight = total_weight

	if current_state == State.KNOCKED_OUT:
		chance_to_say_phrase(knocked_out_phrases, 3)
	else:
		var random_number = randf_range(0.0, total_weight)
		for state in state_weights:
			if state.acc_weight > random_number:
				set_state(state.state)
				break
	var random_wait_time = randi_range(2,5)
	timer.start(random_wait_time)


func _on_hurt_box_area_entered(area):
	if area == basic_atk_box or area == special_atk_box : return
	chance_to_say_phrase(hurt_phrases, 2)
	var attackers = hurt_box.get_overlapping_areas()
	
	for attack in attackers:
		var damage
		var attacking_mon = attack.get_parent()
		anim_player.play("hurt")
		if elm_type == "WATER" && attacking_mon.elm_type == "EARTH" or elm_type == "FIRE" && attacking_mon.elm_type == "WATER" or elm_type == "EARTH" && attacking_mon.elm_type == "FIRE":
			damage(attacking_mon, 2)
		if elm_type == "WATER" && attacking_mon.elm_type == "FIRE" or elm_type == "FIRE" && attacking_mon.elm_type == "EARTH"  or elm_type == "EARTH" && attacking_mon.elm_type == "WATER":
			damage(attacking_mon, -1)
		if elm_type == "NONE" && attacking_mon.elm_type != "NONE":
			damage(attacking_mon, 1)
		else:
			damage(attacking_mon, 0)
		health_label.text = str(health)
		hp_bar.value = health


func damage(mon, modifier: int):
	var damage = mon.strength + modifier
	damage_label.text = str(damage)
	anim_player.play("damage")
	health -= damage


func chance_to_say_phrase(array, chance : int):
	var rand_num = randi_range(1,chance)
	if rand_num == 1:
		var rand_phrase = array.pick_random()
		phrase.get_node("phrase_timer").start(2)
		phrase.text = rand_phrase
		await phrase.get_node("phrase_timer").timeout
		phrase.text = ""


func attack(attack_type):
	if attack_timer.time_left > 0:
		timer.paused = true
		z_index = default_z_index + 1
		attack_type.get_node(str(attack_type.name) + "_coll").disabled = false
	else:
		attack_type.get_node(str(attack_type.name) + "_coll").disabled = true
		z_index = default_z_index
		timer.paused = false


func switch_round_modes(fight_time):
	if fight_time:
		set_state(State.START_FIGHT)
	else:
		set_state(State.UPGRADE)


func move_to_destination(delta):
	if position.x <= destination.x :
		$sprite.flip_h = false
	else:
		$sprite.flip_h = true
	position = position.move_toward(destination, speed * delta)