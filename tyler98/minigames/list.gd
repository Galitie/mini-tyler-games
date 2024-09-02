extends Interactable
@onready var item = get_parent().owner.get_parent()
@onready var particles = get_parent().owner.get_node("%particles")

func _ready():
	get_tree().get_root().get_node("main").refresh_list.connect(_refresh_list)
	var list_of_items = item.string_list
	for item in list_of_items:
		$list.add_item(item)

func _refresh_list():
	print("signal recieved!")
	$list.clear()
	var list_of_items = item.string_list
	for item in list_of_items:
		$list.add_item(item)