extends CharacterBody2D

var tyler_type: String
var max_health: int = 3
var health: int = max_health
var speed: int = 75
var intelligence: int = 1
var strength: int = 1
var strength_mod: float = .20
var elm_type = "NONE"
var current_state = State.IDLE
var destination : Vector2
var default_z_index = 0
var current_player_command = State.IDLE

signal knocked_out

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
	{"state": State.PLAYER_COMMAND, "roll_weight": 1, "acc_weight": 0, "mult": 5}
]
  
@onready var anim_player_attack = $anim_player_attack
@onready var anim_player_hurt = $anim_player_hurt
@onready var anim_player_damage = $anim_player_damage
@onready var timer = $timer
@onready var attack_timer = $attack_timer
@onready var charge_timer = $charge_timer
@onready var block_timer = $block_timer
@onready var hp_bar = $hp_bar
@onready var health_label = $hp_bar/hp_container/current_health
@onready var max_health_label = $hp_bar/hp_container/max_health
@onready var hurt_box = $hurt_box
@onready var basic_atk_box = $basic_atk_box
@onready var special_atk_box = $special_atk_box
@onready var fight_pos = position
@onready var upgrade_pos = Vector2(position.x + 180, position.y - 20)
@onready var phrase = $phrase
@onready var damage_label = $damage_taken


var bored_phrases = ["Whatever", "ZZZ", "Meh", "IDK", "*shrugs*", "???", "I'm bored"]
var target_phrases = ["Charge!", "For Frodo!", "Liberty or Death!", "Leeeroy Jenkins!", "I have the power!"]
var attack_phrases = ["DIE!", "Justice!", "HI-YAH!", "Take that!", "I need the last hit"]
var hurt_phrases = ["Ouch!", "YEOW!", "!", "I need help!", "Don't touch me!", ">:(", "Ow!", "How dare!", "Oof!", "Good grief!", "Jeez!", "Eep!", "Yikes!", "Zoinks!", "argh!"]
var knocked_out_phrases = ["Avenge me!", "X.X", "RIP", ":(", "T.T", "RIPAROONIE", "Alas...", "Think of me", "dang it", "c'mon!", "aw nuts", "D'oh!", "Rats!"]
var listening_phrases = ["Aye-aye!", "I'm on it!", "Roger roger", "I'm all ears", "No problem", "Understood", "Acknowledged", "Yes master", "say no more", "You bet!", "Loud and clear!"]
var blocking_phrases = ["Not this time!", "Not today!", "NOPE", "Get back!", "Can't touch this"]


func _ready():
	phrase.text = ""
	get_parent().connect("send_command", get_command)


func _physics_process(delta):
	if health <= 0 and current_state != State.KNOCKED_OUT:
		set_state(State.KNOCKED_OUT)
	move_and_slide()
	update_state(current_state, delta)


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
	var random_wait_time = randi_range(1,2.5)
	timer.start(random_wait_time)


func set_state(state):
	match state:
		State.WALK_RANDOM:
			chance_to_say_phrase(bored_phrases, 2)
			destination = Vector2(randi_range(100,1000), randi_range(100, 500))
		
		State.BASIC_ATTACK:
			timer.paused = true
			velocity = Vector2()
			chance_to_say_phrase(attack_phrases, 4)
			z_index = default_z_index + 1
			anim_player_attack.play("basic_atk")
			basic_atk_box.get_child(0).disabled = false
			attack_timer.start(.3)
		
		State.CHARGE_UP:
			timer.paused = true
			velocity = Vector2()
			anim_player_attack.play("charge_up")
			charge_timer.start(2)
			z_index = default_z_index + 1
		
		State.SPECIAL_ATTACK:
			timer.paused = true
			velocity = Vector2()
			chance_to_say_phrase(attack_phrases, 4)
			z_index = default_z_index + 1
			anim_player_attack.play("special_atk")
			special_atk_box.get_child(0).disabled = false
			attack_timer.start(.3)
		
		State.IDLE:
			velocity = Vector2()
			chance_to_say_phrase(bored_phrases, 1)
		
		State.KNOCKED_OUT:
			emit_signal("knocked_out")
			chance_to_say_phrase(knocked_out_phrases, 3)
			timer.paused = true
			z_index = default_z_index - 1
			get_node("collision").disabled = true
			hurt_box.get_child(0).disabled = true
			velocity = Vector2()
			anim_player_attack.play("knocked_out")
			hp_bar.visible = false

		State.TARGET_AND_GO:
			chance_to_say_phrase(target_phrases, 4)
			destination = get_other_random_mon().position
		
		State.TARGET_AND_ATTACK:
			chance_to_say_phrase(target_phrases, 4)
			destination = get_other_random_mon().position

		State.TARGET_AND_SPECIAL:
			chance_to_say_phrase(target_phrases, 4)
			destination = get_other_random_mon().position
		
		State.BLOCK:
			chance_to_say_phrase(blocking_phrases, 4)
			velocity = Vector2()
			block_timer.start(2.5)
			anim_player_hurt.play("block")
			timer.paused = true
			z_index = default_z_index + 1
			hurt_box.get_child(0).disabled = true

		State.PLAYER_COMMAND:
			chance_to_say_phrase(listening_phrases, 1)
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
			pass


func get_other_random_mon():
	var get_all_mons = get_tree().get_nodes_in_group("mons")
	var random_mon = get_all_mons.pick_random()
	while random_mon == self or random_mon.current_state == State.KNOCKED_OUT:
		random_mon = get_all_mons.pick_random()
	return random_mon


func _on_hurt_box_area_entered(area):
	if area == basic_atk_box or area == special_atk_box : return
	chance_to_say_phrase(hurt_phrases, 2)
	var attackers = hurt_box.get_overlapping_areas()
	for attack in attackers:
		var attacking_mon = attack.get_parent()
		anim_player_hurt.play("hurt")
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
	if health <= roundi(max_health * .25):
		hp_bar.get_theme_stylebox("fill").bg_color = Color(1, 0.337, 0.333)


func damage(mon, modifier: int):
	var damage = mon.strength + modifier
	if mon.current_state == State.SPECIAL_ATTACK:
		damage += 1 + roundi(mon.strength * strength_mod)
	damage_label.text = str(damage)
	anim_player_damage.play("damage")
	health -= damage


func chance_to_say_phrase(array, chance : int):
	var rand_num = randi_range(1,chance)
	if rand_num == 1:
		var rand_phrase = array.pick_random()
		phrase.get_node("phrase_timer").start(2)
		phrase.text = rand_phrase
		await phrase.get_node("phrase_timer").timeout
		phrase.text = ""


func switch_round_modes(fight_time):
	if fight_time:
		velocity = Vector2()
		timer.start(.5)
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
	else:
		timer.stop()
		velocity = Vector2()
		position = upgrade_pos
		if current_state == State.KNOCKED_OUT:
			anim_player_attack.play("get_up")
			hp_bar.visible = true
		set_state(State.IDLE)
		health = max_health
		health_label.text = str(max_health)
		hp_bar.max_value = max_health
		hp_bar.value = max_health
		hp_bar.get_theme_stylebox("fill").bg_color = Color(0, 0.727, 0.147)


func move_to_destination(delta):
	if position.x <= destination.x :
		$sprite.flip_h = false
	else:
		$sprite.flip_h = true
	position = position.move_toward(destination, speed * delta)


func get_command(command, player_index):
	var player = get_parent().name
	if player.split("player")[1] == str(player_index):
		print("mon", player_index + 1, " recieved command ", State.keys()[command])
		current_player_command = command


func _on_attack_timer_timeout():
	if current_state == State.IDLE or current_state == State.KNOCKED_OUT:
		return
	else:
		timer.paused = false
		basic_atk_box.get_child(0).disabled = true
		special_atk_box.get_child(0).disabled = true
		z_index = default_z_index


func _on_block_timer_timeout():
	if current_state == State.IDLE or current_state == State.KNOCKED_OUT:
		return
	else:
		timer.paused = false
		hurt_box.get_child(0).disabled = false
		z_index = default_z_index


func _on_charge_timer_timeout():
	z_index = default_z_index
	if current_state == State.IDLE or current_state == State.KNOCKED_OUT:
		return
	else:
		set_state(State.SPECIAL_ATTACK)
