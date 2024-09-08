extends Interactable


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func click(area, _pointer):
	if area.get_parent().name == "reset":
		get_parent().window_open = false
		get_tree().get_root().get_node("main").task_completed(1)
		queue_free()
		
	if area.get_parent().name == "help":
		get_parent().window_open = false
		queue_free()
