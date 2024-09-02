extends Interactable

@export var goal_number: int
@onready var item = get_parent().owner.get_parent()
var id
@onready var particles = get_parent().owner.get_node("%particles")


func _ready():
	%output.text = ""
	id = item.task_id


func check_goal_met():
	if %output.text == str(goal_number) + "*":
		item.exhausted = true
		particles.emitting = true
		await particles.finished
		get_tree().get_root().get_node("main").task_completed(id)
		get_parent().owner.queue_free()
	
	else:
		%output.text = ""


func click(area, pointer):
	if %output.text.length() < 4:
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
				check_goal_met()
	else:
		match area.get_parent().name:
			"back":
				%output.text = ""
			"enter":
				%output.text += "*"
				check_goal_met()
