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
enum State {WALK_RANDOM, BASIC_ATTACK, IDLE, SPECIAL_ATTACK}
var destination : Vector2 
var target
var change_mind
@onready var anim_player = $anim_player
@onready var timer = $timer

func _ready():
	current_state = State.IDLE
	change_mind = false
	timer.wait_time = 1
	timer.start()

func _physics_process(delta):
	move_and_slide()
	#if velocity.length() > 0:
		#animation here
		#pass
	update_state(current_state, delta)
	if change_mind:
		var random_number = randi_range(0, 50)
		if random_number < 10:
			set_state(State.WALK_RANDOM)
			print("walk_random")
		if random_number > 10 and random_number < 20:
			set_state(State.BASIC_ATTACK)
			print("basic_attack")
		if random_number > 20 and random_number < 30:
			set_state(State.IDLE)
			print("idle")
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
			destination = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
		State.BASIC_ATTACK:
			velocity = Vector2()
			pass
			#var attack = attacks.random()
			#anim_player.play(attack.name)
		State.IDLE:
			velocity = Vector2()
	current_state = state


func update_state(state, delta):
	match state:
		State.WALK_RANDOM:
			velocity = destination * speed 
		State.BASIC_ATTACK:
			pass
		State.IDLE:
			pass


func _on_timer_timeout():
	change_mind = true
