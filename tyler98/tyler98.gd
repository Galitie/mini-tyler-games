extends Control
var priority_window = null
var logging_in_texture = load("res://tyler98/logging_in_image.png")
@onready var todo_list = %todo_list
signal refresh_list
signal enable_area

var task_counter = 0
# mini_games must also queue free themselves if they are to be deleted by the main game
# right now I have a workaround that loops through all of areas/windows backwards lol
# Make main screen items unclickable while in start_screen

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
			$audio.stream = load("res://tyler98/sfx/startup.mp3")
			$audio.play()
			%background.texture = logging_in_texture
			await $audio.finished
			task_handler(id)
			$start_screen.queue_free()
			enable_area.emit()
		1:
			pass
		2:
			pass
		3: 
			pass
	check_for_gameover()


func task_handler(id):
	todo_list.string_list.insert(id, "")
	todo_list.string_list.remove_at(id+1)
	refresh_list.emit()
	task_counter += 1


func check_for_gameover():
	if task_counter == todo_list.string_list.size():
		print("game over!")
