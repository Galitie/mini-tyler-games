extends Control
var priority_window = null
# mini_games must also queue free themselves if they are to be deleted by the main game

# Priority order for windows and interactions:
	# Priority when spawned, priority when dragging or interacting
	# One window has the most priority at a time?
	
# Only interact with top window, not windows below the top window

# success feedback for mini games
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
		0:
			$start_screen.queue_free()
		1:
			pass
		2:
			pass
		3:
			pass
