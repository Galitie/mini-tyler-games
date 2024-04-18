extends CharacterBody2D

var tyler_type: String
var attacks
var health: int = 10
var speed: int = 150
var intelligence: int = 5
var strength: int = 1
var elm_type
var commands
var current_state : State
enum State {WALK_RANDOM, BASIC_ATTACK, IDLE, SPECIAL_ATTACK, KNOCKED_OUT}
var destination : Vector2 
var target
var change_mind
@onready var anim_player = $anim_player
@onready var timer = $timer
@onready var hp_bar = $hp_bar
@onready var hurt_box = $hurt_box
@onready var basic_atk_box = $basic_atk_box

func _ready():
	current_state = State.IDLE
	change_mind = false
	hp_bar.max_value = health
	hp_bar.value = health
	timer.wait_time = 1
	basic_atk_box.get_child(0).disabled = true
	timer.start()


func _physics_process(delta):
	if health <= 0:
		set_state(State.KNOCKED_OUT)
	move_and_slide()
	#if velocity.length() > 0:
		#walking animation here
	update_state(current_state, delta)
	if change_mind and current_state != State.KNOCKED_OUT:
		var random_number = randi_range(0, 50)
		if random_number < 10:
			set_state(State.WALK_RANDOM)
		if random_number > 10 and random_number < 20:
			set_state(State.BASIC_ATTACK)
		if random_number > 20 and random_number < 30:
			set_state(State.IDLE)
		if random_number > 30 and random_number < 40:
			pass
			#set_state(player.requested_state)
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
		State.IDLE:
			basic_atk_box.get_child(0).disabled = true
			velocity = Vector2()
		State.KNOCKED_OUT:
			basic_atk_box.get_child(0).disabled = true
			velocity = Vector2()
			$sprite.rotation = 90
	current_state = state


func update_state(state, delta):
	match state:
		State.WALK_RANDOM:
			velocity = destination * speed 
		State.BASIC_ATTACK:
			basic_atk_box.get_child(0).disabled = false
		State.IDLE:
			pass


func _on_timer_timeout():
	change_mind = true


func _on_hurt_box_area_entered(area):
	if area == basic_atk_box: return
	print("mon was hit!")
	health -= 5
	hp_bar.value = health
