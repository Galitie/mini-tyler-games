extends Interactable
@onready var item_label_title = %item_name
@onready var item_label_description = %description
@onready var item = get_parent()

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


func click(area):
	queue_free()
