extends Interactable



func _ready():
	pass # Replace with function body.


func _process(_delta):
	pass


func click(area, _pointer):
	if area.get_parent().name == "reset":
		get_parent().window_open = false
		get_tree().get_root().get_node("main").task_completed(1)
		queue_free()
		
	if area.get_parent().name == "help":
		get_parent().window_open = false
		get_tree().get_root().get_node("main").task_completed(5)
		queue_free()
