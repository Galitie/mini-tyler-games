extends Interactable
@onready var item_label_title = %item_name
@onready var item_label_description = %description
@onready var item = get_parent()
@onready var draggable_shape = %shape
var size_set : bool = false

func _ready():
	item_label_title.text = item.item_name
	item_label_description.text = item.item_description		
	
	var mini_game = item.window_scene
	mini_game = mini_game.instantiate()
	%margin.add_child(mini_game)
	
	if item.scene_var_str != "":
		mini_game.goal_number = item.scene_var_str
	if item.scene_var_int != 0:
		mini_game.goal_rotation = item.scene_var_int

func _process(delta):
	if size_set == false:
		set_draggable_shape()

func click(area):
	if area.name == "text_box_area":
		return
	item.window_open = false
	queue_free()


func drag(pointer, delta):
	print("dragging")
	pass

func set_draggable_shape():
	draggable_shape.shape.size = %text_hbox.size
	draggable_shape.position = Vector2(%text_hbox.size.x / 2, %text_hbox.size.y / 2)
	size_set = true
