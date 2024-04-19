extends CharacterBody2D

var tyler_type: String
var attacks
var max_health: int = 3
var health: int = max_health
var speed: int = 75
var intelligence: int = 0
var strength: int = 1
var elm_type = "normal"
var commands
var current_state 
var destination : Vector2
enum State {
	WALK_RANDOM, BASIC_ATTACK, IDLE,
 	SPECIAL_ATTACK, KNOCKED_OUT, TARGET_AND_GO,
	PLAYER_COMMAND, START_FIGHT, UPGRADE
	}


@onready var anim_player = $anim_player
@onready var timer = $timer
@onready var hp_bar = $hp_bar
@onready var hurt_box = $hurt_box
@onready var basic_atk_box = $basic_atk_box
@onready var special_atk_box = $special_atk_box
@onready var fight_pos = position
@onready var phrase = $phrase

var bored_phrases = ["Whatever", "ZZZ", "Meh", "IDK", "*shrugs*", "Huh?", "Pff"]
var target_phrases = ["Charge!", "For Frodo!", "Liberty or Death!", "Leeeroy Jenkins!", "I have the power!"]
var attack_phrases = ["DIE!", "Not today!", "Justice!", "HI-YAH!", "Take that!"]
var hurt_phrases = ["Ouch!", "YEOW!", "!", "I need help!", "Don't touch me!", ">:(", "Ow!", "How dare!", "Oof!", "Good grief!", "Jeez!", "Eep!", "Yikes!", "Zoinks!", "argh!"]
var knocked_out_phrases = ["Avenge me!", "X.X", "RIP", ":(", "T.T", "RIPAROONIE", "Alas...", "Think of me", "dang it", "c'mon!", "aw nuts", "D'oh!", "Rats!"]
var listening_phrases = ["Aye-aye!", "I'm on it!", "Roger roger", "I'm all ears", "No problem", "Understood", "Acknowledged", "Yes master", "say no more", "You bet!"]


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
			chance_to_say_phrase(bored_phrases)
			destination = Vector2(randi_range(100,1000), randi_range(100, 500))
		
		State.BASIC_ATTACK:
			attack(basic_atk_box)
		
		State.SPECIAL_ATTACK:
			attack(special_atk_box)
		
		State.IDLE:
			chance_to_say_phrase(bored_phrases)
		
		State.KNOCKED_OUT:
			get_node("collision").disabled = true
			hurt_box.get_child(0).disabled = true
			chance_to_say_phrase(knocked_out_phrases)
			anim_player.play("knocked_out")
			z_index = -1
			hp_bar.visible = false

		State.TARGET_AND_GO:
			chance_to_say_phrase(target_phrases)
			destination = get_other_random_mon().position
			
		State.PLAYER_COMMAND:
			chance_to_say_phrase(listening_phrases)

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
			timer.paused = false
			timer.start(1)
		
		State.UPGRADE:
			timer.paused = true
			position = fight_pos
			position.x = position.x + 80
			if current_state == State.KNOCKED_OUT:
				anim_player.speed_scale = -1
				anim_player.play("knocked_out")
				await anim_player.animation_finished
				anim_player.speed = 1
				hp_bar.visible = true
			health = max_health
			hp_bar.max_value = max_health
			hp_bar.value = max_health
			#upgrade animation
	current_state = state


func update_state(state, delta):
	match state:
		State.WALK_RANDOM:
			if position.x <= destination.x:
				$sprite.flip_h = false
			else:
				$sprite.flip_h = true
			position = position.move_toward(destination, speed * delta)

		State.TARGET_AND_GO:
			if position.x <= destination.x:
				$sprite.flip_h = false
			else:
				$sprite.flip_h = true
			position = position.move_toward(destination, speed * delta)
		
		State.UPGRADE:
			velocity = Vector2()

		State.BASIC_ATTACK:
			velocity = Vector2()
		
		State.SPECIAL_ATTACK:
			velocity = Vector2()
			
		State.START_FIGHT:
			velocity = Vector2()

func get_other_random_mon():
	var get_all_mons = get_tree().get_nodes_in_group("mons")
	var random_mon = get_all_mons.pick_random()
	while random_mon == self or random_mon.current_state == State.KNOCKED_OUT:
		random_mon = get_all_mons.pick_random()
	return random_mon


func _on_timer_timeout():
	if current_state == State.KNOCKED_OUT:
		chance_to_say_phrase(knocked_out_phrases)
	else:
		var random_number = randi_range(0, 50) + intelligence
		if random_number <= 10:
			set_state(State.IDLE)
		if random_number > 10 and random_number <= 20:
			set_state(State.WALK_RANDOM)
		if random_number > 20 and random_number <= 30:
			set_state(State.BASIC_ATTACK)
		if random_number > 30 and random_number <= 40:
			set_state(State.TARGET_AND_GO)
		if random_number > 40 and random_number < 50:
			set_state(State.SPECIAL_ATTACK)
		if random_number >= 50:
			set_state(State.PLAYER_COMMAND)
			#do what the player says
	var random_wait_time = randi_range(2,5)
	timer.start(random_wait_time)


func _on_hurt_box_area_entered(area):
	if area == basic_atk_box or area == special_atk_box : return
	chance_to_say_phrase(hurt_phrases)
	var attackers = hurt_box.get_overlapping_areas()
	for attack in attackers:
		var attacking_mon = attack.get_parent()
		anim_player.play("hurt")
		health -= attacking_mon.strength
		hp_bar.value = health


func chance_to_say_phrase(array):
	var chance = randi_range(1,4)
	if chance == 1:
		var rand_phrase = array.pick_random()
		phrase.get_node("phrase_timer").start(2.5)
		phrase.text = rand_phrase
		await phrase.get_node("phrase_timer").timeout
		phrase.text = ""


func attack(attack_type):
	chance_to_say_phrase(attack_phrases)
	attack_type.get_node(str(attack_type.name) + "_coll").disabled = false
	z_index +=  1
	timer.paused = true
	anim_player.play(str(attack_type.name).split("_box")[0])
	await anim_player.animation_finished
	attack_type.get_node(str(attack_type.name) + "_coll").disabled = true
	timer.paused = false
	z_index -= 1


func switch_round_modes(fight_time):
	if fight_time:
		set_state(State.START_FIGHT)
	else:
		set_state(State.UPGRADE)
