extends CharacterBody2D

var tyler_type: String
var attacks
var health: int = 10
var speed: int = 1
var intelligence: int = 10
var strength: int = 1
var elm_type = null
var commands
enum state {}

func _ready():
	pass


func set_state(state):
	#match state:
		pass

func update_state(state):
	pass

func _physics_process(delta):
	update_state(state)
	#move_and_slide()
	if velocity.length() > 0:
		#animation here
		pass
		
	if velocity.x > 0:
		$sprite.flip_h = false
	else:
		$sprite.flip_h = true
