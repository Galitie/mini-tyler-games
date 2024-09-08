extends Interactable
@onready var item = get_parent().owner.get_parent()
var counter = 0

func _ready():
	pass


func _process(_delta):
	pass


func add_to_counter():
	counter += 1
	if counter == 1:
		get_tree().get_root().get_node("main").task_completed(2)
		item.exhausted = true
