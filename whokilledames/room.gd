extends Node2D

var current_view

# Called when the node enters the scene tree for the first time.
func _ready():
	current_view = get_node("views/room_view_1")
	var pointers = get_tree().get_nodes_in_group("pointer")
	for pointer in pointers:
		pointer.change_room.connect(_change_views)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _change_views(direction):
	match current_view.name:
		"room_view_1":
			if direction == "left":
				current_view = get_node("views/room_view_2")
			else:
				current_view = get_node("views/room_view_2")
			var views = get_tree().get_nodes_in_group("room_view")
			for view in views:
				view.visible = false
			current_view.visible = true
		"room_view_2":
			if direction == "left":
				current_view = get_node("views/room_view_1")
			else:
				current_view = get_node("views/room_view_1")
			var views = get_tree().get_nodes_in_group("room_view")
			for view in views:
				view.visible = false
			current_view.visible = true
