extends Interactable
@onready var item = get_parent().owner.get_parent()


func _ready():
	pass


func _process(_delta):
	pass


func add_to_counter(item_name):
	match item_name:
		"SxS":
			get_tree().get_node("%prawn").item1 = true
		"snake":
			get_tree().get_node("%prawn").item2 = true
		"Mmm":
			get_tree().get_node("%prawn").item3 = true
		"Xxx":
			get_tree().get_node("%prawn").item4 = true

