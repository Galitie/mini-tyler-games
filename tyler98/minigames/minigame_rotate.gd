extends Interactable
@export var goal_rotation: int

@onready var item = get_parent().owner.get_parent()
var current_rotation_degree: int

func _ready():
	$sprite.texture = item.sprite	


func _process(_delta):
	current_rotation_degree = $sprite.rotation_degrees
	check_goal_met()


func check_goal_met():
	if current_rotation_degree >= goal_rotation - 5 and current_rotation_degree < goal_rotation + 5 or current_rotation_degree >= -goal_rotation - 5 and current_rotation_degree < -goal_rotation + 5:
		item.exhausted = true


func drag(pointer):
	pass
	#var vec = pointer.global_position - $sprite.global_position
	#var angle = vec.angle()
	#var rotate = $sprite.global_rotation
	#var angle_delta = PI * delta
	#angle = lerp_angle(rotate, angle, 1.0)
	#angle = clamp(angle, rotate - angle_delta, rotate + angle_delta)
	#$sprite.global_rotation = angle
