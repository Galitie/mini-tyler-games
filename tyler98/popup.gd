extends Interactable

@onready var item_label_title = %item_name
@onready var item_label_description = %description
@onready var item = get_parent()
@onready var draggable_shape = %shape

var size_set : bool = false
var dragging : bool = false
var drag_offset

func _ready():
	get_tree().get_root().get_node("main").set_priority_window(self)
	$sfx.play()
	item_label_title.text = item.item_name
	item_label_description.text = item.item_description		
	
	var mini_game = item.window_scene
	mini_game = mini_game.instantiate()	
	%margin.add_child(mini_game)
	
	if item.scene_var_str != "":
		mini_game.goal_number = item.scene_var_str
	if item.scene_var_int != 0:
		mini_game.goal_rotation = item.scene_var_int


func _process(_delta):
	global_position.x = clamp(global_position.x, 95 + $panel.size.x / 2, 1190 - $panel.size.x / 2)
	global_position.y = clamp(global_position.y, 5 + $panel.size.y / 2, 725 - $panel.size.y / 2)
	if size_set == false:
		set_draggable_shape()


func click(area, pointer):
	get_tree().get_root().get_node("main").set_priority_window(self)
	if area == %text_box_area:
		drag_offset = global_position - pointer.global_position
		return
	item.window_open = false
	queue_free()


func drag(pointer):
	get_tree().get_root().get_node("main").set_priority_window(self)
	global_position = pointer.global_position + drag_offset


func set_draggable_shape():
	draggable_shape.shape.size = %text_hbox.size
	draggable_shape.position = Vector2(%text_hbox.size.x / 2, %text_hbox.size.y / 2)
	size_set = true
