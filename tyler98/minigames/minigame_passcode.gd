extends Control
class_name PasscodeMiniGame
@export var goal_number: int
@onready var item = get_parent().owner.owner


func _ready():
	%output.text = ""
	pass


func _process(_delta):
	check_goal_met()


func check_goal_met():
	if %output.text == str(goal_number) + "*":
		item.exhausted = true
	if %output.text.contains("*"):
		%output.text = ""
