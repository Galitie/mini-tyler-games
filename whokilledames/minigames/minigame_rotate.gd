extends Control
class_name RotateMiniGame
@export var goal_rotation: int
var current_rotation_degree: int
@onready var item = get_parent().owner.owner


func _ready():
	$sprite.texture = item.sprite	


func _process(_delta):
	current_rotation_degree = $sprite.rotation_degrees
	check_goal_met()


func check_goal_met():
	if current_rotation_degree >= goal_rotation - 5 and current_rotation_degree < goal_rotation + 5 or current_rotation_degree >= -goal_rotation - 5 and current_rotation_degree < -goal_rotation + 5:
		print("you did it!")
		item.exhausted = true
