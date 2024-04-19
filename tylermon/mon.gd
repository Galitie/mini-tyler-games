extends CharacterBody2D

var tyler_type: String
var attacks
var max_health: int = 10
var health: int = max_health
var speed: int = 150
var intelligence: int = 0
var strength: int = 1
var elm_type
var commands
var current_state 
var destination : Vector2 
var change_mind
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
	if health <= 0:
		set_state(State.KNOCKED_OUT)
	move_and_slide()
	update_state(current_state, delta)
	if change_mind and current_state != State.KNOCKED_OUT:
		var random_number = randi_range(0, 50) + intelligence
		if random_number < 10:
			set_state(State.IDLE)
		if random_number > 10 and random_number < 20:
			set_state(State.WALK_RANDOM)
		if random_number > 20 and random_number < 30:
			set_state(State.BASIC_ATTACK)
		if random_number > 30 and random_number < 40:
			set_state(State.TARGET_AND_GO)
		if random_number > 40 and random_number <= 50:
			pass
			#do what player said
	if velocity.x > 0:
		$sprite.flip_h = false
	else:
		$sprite.flip_h = true
	change_mind = false


func set_state(state):
	match state:
		State.WALK_RANDOM:
			basic_atk_box.get_child(0).disabled = true
			destination = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
		State.BASIC_ATTACK:
			velocity = Vector2()
			pass
			#var attack = attacks.random()
			#anim_player.play(attack.name)
			#when animation is done, go back to changing the state
		State.IDLE:
			basic_atk_box.get_node("basic_atk_box_coll").disabled = true
			velocity = Vector2()
		State.KNOCKED_OUT:
			basic_atk_box.get_node("basic_atk_box_coll").disabled = true
			velocity = Vector2()
			$sprite.rotation = 90
		State.TARGET_AND_GO:
			basic_atk_box.get_node("basic_atk_box_coll").disabled = true
			destination = get_other_random_mon().position.normalized()
		State.START_FIGHT:
			position = fight_pos
			change_mind = false
			$sprite.rotation = 0
			basic_atk_box.get_node("basic_atk_box_coll").disabled = true
			health = max_health
			hp_bar.max_value = max_health
			hp_bar.value = health
			hp_bar.value = max_health
			timer.wait_time = 1
			timer.start()
		State.UPGRADE:
			position.x = position.x + 80
			$sprite.rotation = 0
			#animation
	current_state = state


func update_state(state, delta):
	match state:
		State.WALK_RANDOM:
			velocity = destination * speed 
		State.BASIC_ATTACK:
			basic_atk_box.get_node("basic_atk_box_coll").disabled = false
		State.IDLE:
			pass
			#idle animation
		State.TARGET_AND_GO:
			velocity = destination * speed


func get_other_random_mon():
	var get_all_mons = get_tree().get_nodes_in_group("mons")
	var random_mon = get_all_mons.pick_random()
	while random_mon == self && random_mon.current_state != State.KNOCKED_OUT:
		random_mon = get_all_mons.pick_random()
	return random_mon


func _on_timer_timeout():
	change_mind = true


func _on_hurt_box_area_entered(area):
	if area == basic_atk_box: return
	var attackers = hurt_box.get_overlapping_areas()
	for attack in attackers:
		var attacking_mon = attack.get_parent()
		health -= attacking_mon.strength
		hp_bar.value = health
