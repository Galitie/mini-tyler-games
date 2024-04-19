extends CharacterBody2D

var tyler_type: String
var attacks
var max_health: int = 5
var health: int = max_health
var speed: int = 75
var intelligence: int = 0
var strength: int = 3
var elm_type
var commands
var current_state 
var destination : Vector2
enum State {WALK_RANDOM, BASIC_ATTACK, IDLE, SPECIAL_ATTACK, KNOCKED_OUT, TARGET_AND_GO, START_FIGHT, UPGRADE}


@onready var anim_player = $anim_player
@onready var timer = $timer
@onready var hp_bar = $hp_bar
@onready var hurt_box = $hurt_box
@onready var basic_atk_box = $basic_atk_box
@onready var fight_pos = position

func _ready():
	set_state(State.START_FIGHT)


func _physics_process(delta):
	if health <= 0 and current_state != State.KNOCKED_OUT:
		set_state(State.KNOCKED_OUT)
	move_and_slide()
	update_state(current_state, delta)


func set_state(state):
	match state:
		State.WALK_RANDOM:
			basic_atk_box.get_child(0).disabled = true
			destination = Vector2(randi_range(100,1000), randi_range(100, 500))
		
		State.BASIC_ATTACK:
			basic_atk_box.get_node("basic_atk_box_coll").disabled = false
			z_index = 1
			velocity = Vector2()
			timer.paused = true
			# var attack = attacks.random()
			anim_player.play("basic_attack")
			await anim_player.animation_finished
			basic_atk_box.get_node("basic_atk_box_coll").disabled = true
			timer.paused = false
			z_index = 0
		
		State.IDLE:
			basic_atk_box.get_node("basic_atk_box_coll").disabled = true
			velocity = Vector2()
		
		State.KNOCKED_OUT:
			anim_player.play("knocked_out")
			z_index = -1
			basic_atk_box.get_node("basic_atk_box_coll").disabled = true
			velocity = Vector2()
			get_node("collision").disabled = true
			hp_bar.visible = false

		State.TARGET_AND_GO:
			basic_atk_box.get_node("basic_atk_box_coll").disabled = true
			destination = get_other_random_mon().position

		State.START_FIGHT:
			hp_bar.visible = true
			get_node("collision").disabled = false
			position = fight_pos
			basic_atk_box.get_node("basic_atk_box_coll").disabled = true
			health = max_health
			hp_bar.max_value = max_health
			hp_bar.value = health
			hp_bar.value = max_health
			timer.wait_time = 1
			timer.start()
		
		State.UPGRADE:
			position = fight_pos
			position.x = position.x + 80
			#animation

	current_state = state


func update_state(state, delta):
	match state:
		State.WALK_RANDOM:
			if position.x <= destination.x:
				$sprite.flip_h = false
			else:
				$sprite.flip_h = true
			position = position.move_toward(destination, speed * delta)
			
		State.BASIC_ATTACK:
			#basic_atk_box.get_node("basic_atk_box_coll").disabled = false
			pass

		State.IDLE:
			pass

		State.TARGET_AND_GO:
			if position.x <= destination.x:
				$sprite.flip_h = false
			else:
				$sprite.flip_h = true
			position = position.move_toward(destination, speed * delta)


func get_other_random_mon():
	var get_all_mons = get_tree().get_nodes_in_group("mons")
	var random_mon = get_all_mons.pick_random()
	while random_mon == self or random_mon.current_state == State.KNOCKED_OUT:
		random_mon = get_all_mons.pick_random()
	return random_mon


func _on_timer_timeout():
	if current_state != State.KNOCKED_OUT:
		var random_number = randi_range(0, 50) + intelligence
		if random_number <= 10:
			set_state(State.IDLE)
		if random_number > 10 and random_number <= 20:
			set_state(State.WALK_RANDOM)
		if random_number > 20 and random_number <= 30:
			set_state(State.BASIC_ATTACK)
		if random_number > 30 and random_number <= 40:
			set_state(State.TARGET_AND_GO)
		if random_number > 40 and random_number <= 50:
			pass
			#special attack
		if random_number > 50:
			pass
			#do what the player says
	var random_wait_time = randi_range(2,5)
	timer.start(random_wait_time)

func _on_hurt_box_area_entered(area):
	if area == basic_atk_box: return
	var attackers = hurt_box.get_overlapping_areas()
	for attack in attackers:
		var attacking_mon = attack.get_parent()
		health -= attacking_mon.strength
		hp_bar.value = health
