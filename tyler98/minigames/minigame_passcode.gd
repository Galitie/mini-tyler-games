extends Interactable

@export var goal_number: int
@onready var item = get_parent().owner.get_parent()


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

func click(area):
	match area.get_parent().name:
		"back":
			%output.text = ""
		"0":
			%output.text += "0"
		"1":
			%output.text += "1"
		"2":
			%output.text += "2"
		"3":
			%output.text += "3"
		"4":
			%output.text += "4"
		"5":
			%output.text += "5"
		"6":
			%output.text += "6"
		"7":
			%output.text += "7"
		"8":
			%output.text += "8"
		"9":
			%output.text += "9"
		"enter":
			%output.text += "*"
