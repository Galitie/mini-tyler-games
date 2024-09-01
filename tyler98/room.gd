extends Control

# mini_games must also queue free themselves if they are to be deleted by the main game

# minigame signal tells main game that it is complete (pass ID?)
# success feedback for mini games
# desktop item needs to be more general? Idk how to sort this out...yet
# interactable is the general item?
# Priority order for windows and interactions

func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	


func _process(_delta):
	pass


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
