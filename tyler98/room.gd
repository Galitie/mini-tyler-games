extends Control
var priority_window = null
var logging_in_texture = load("res://tyler98/logging_in_image.png")
@onready var todo_list = %todo_list
signal refresh_list
# mini_games must also queue free themselves if they are to be deleted by the main game
# Only interact with top window? not windows below the top window...right now I have a workaround that loops through all of them backwards lol


# desktop item needs to be more general? Idk how to sort this out...yet
# interactable is the general item?

func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)


func _process(_delta):
	pass


func set_priority_window(window):
	if priority_window == null:
		priority_window = window
		priority_window.z_index += 1
	else:
		priority_window.z_index -= 1
		priority_window = window
		priority_window.z_index += 1


func task_completed(id):
	match id:
		0: #start screen login
			$audio.stream = load("res://tyler98/startup.mp3")
			$audio.play()
			%background.texture = logging_in_texture
			await $audio.finished
			remove_task_from_list(id)
			$start_screen.queue_free()
		1:
			pass
		2:
			pass
		3: #opened task list
			pass


func remove_task_from_list(id):
	todo_list.string_list.insert(id, "")
	todo_list.string_list.remove_at(id+1)
	refresh_list.emit()
