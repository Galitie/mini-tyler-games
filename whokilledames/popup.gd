extends Control
class_name Interactable_Popup
@onready var item_label_title = %item_name
@onready var item_label_description = %description

# Called when the node enters the scene tree for the first time.
func _ready():
	var item = get_parent()
	item_label_title.text = item.item_name
	item_label_description.text = item.item_description

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
