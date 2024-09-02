extends Control
var priority_window = null

# mini_games must also queue free themselves if they are to be deleted by the main game
# Only interact with top window? not windows below the top window...right now I have a workaround that loops through all of them backwards lol

# fix rotate game?

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
			$start_screen.queue_free()
		1:
			pass
		2:
			pass
		3:
			pass
