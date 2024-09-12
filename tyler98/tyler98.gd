extends Control
var priority_window = null
var logging_in_texture = load("res://tyler98/logging_in_image.png")
@onready var todo_list = %todo_list
var screensaver_mode = true
var gameover = false

signal refresh_list
signal enable_desktop_areas
signal disable_desktop_areas
signal enable_start_screen
signal disable_start_screen

var task_counter = 0
# mini_games must also queue free themselves if they are to be deleted by the main game
# right now I have a workaround that loops through all of areas/windows backwards lol


func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)


func _process(_delta):
	if Controller.IsControllerButtonJustPressed(0, JOY_BUTTON_A) and screensaver_mode:
		$screensaver.paused = true
		$screensaver.visible = false
		screensaver_mode = false
	if Controller.IsControllerButtonJustPressed(1, JOY_BUTTON_A) and screensaver_mode:
		$screensaver.paused = true
		$screensaver.visible = false
		screensaver_mode = false
	if Controller.IsControllerButtonJustPressed(2, JOY_BUTTON_A) and screensaver_mode:
		$screensaver.paused = true
		$screensaver.visible = false
		screensaver_mode = false
	if Controller.IsControllerButtonJustPressed(3, JOY_BUTTON_A) and screensaver_mode:
		$screensaver.paused = true
		$screensaver.visible = false
		screensaver_mode = false
	if gameover == true:
		if Controller.IsControllerButtonJustPressed(0, JOY_BUTTON_A):
			await Globals.FadeIn(.25)
			Globals.GoToMainMenu()
			return
		if Controller.IsControllerButtonJustPressed(1, JOY_BUTTON_A):
			await Globals.FadeIn(.25)
			Globals.GoToMainMenu()
			return
		if Controller.IsControllerButtonJustPressed(2, JOY_BUTTON_A):
			await Globals.FadeIn(.25)
			Globals.GoToMainMenu()
			return
		if Controller.IsControllerButtonJustPressed(3, JOY_BUTTON_A):
			await Globals.FadeIn(.25)
			Globals.GoToMainMenu()
			return


func set_priority_window(window):
	if priority_window == null:
		priority_window = window
		priority_window.z_index += 1
	else:
		priority_window.z_index -= 1
		priority_window = window
		priority_window.z_index += 1


func drop_priority_window():
	if priority_window != null:
		priority_window.z_index -= 1
		priority_window = null


func task_completed(id):
	match id:
		0: #start screen login
			$audio.stream = load("res://tyler98/sfx/startup.mp3")
			$audio.play()
			%background.texture = logging_in_texture
			%background.visible = true
			await $audio.finished
			task_handler(id)
			$start_screen.visible = false
			disable_start_screen.emit()
			enable_desktop_areas.emit()
		
		1: #Update and restart computer
			if todo_list.string_list[id] != "":
				get_node("%start_menu").get_node("%particles").emitting = true
				$audio.stream = load("res://tyler98/sfx/success.mp3")
				$audio.play()
				await $audio.finished
			$audio.stream = load("res://tyler98/sfx/shutdown.mp3")
			$audio.play()
			drop_priority_window()
			await Globals.FadeIn(.25)
			enable_start_screen.emit()
			disable_desktop_areas.emit()
			await Globals.FadeOut()
			task_handler(id)
		
		2: #Change desktop wallpaper
			$audio.stream = load("res://tyler98/sfx/success.mp3")
			$audio.play()
			task_handler(id)
			
		3: #Delete dirty photos
			task_handler(id)
			$audio.stream = load("res://tyler98/sfx/success.mp3")
			$audio.play()
			await $audio.finished
		
		4: #calculator
			task_handler(id)
		
		5: #Get help
			if todo_list.string_list[id] != "":
				get_node("%start_menu").get_node("%particles").emitting = true
				$audio.stream = load("res://tyler98/sfx/success.mp3")
				$audio.play()
				task_handler(id)
		
		6:#Connect to internet
			task_handler(id)
	
	check_for_gameover()


func task_handler(id):
	if todo_list.string_list[id] != "":
		todo_list.string_list.insert(id, "")
		todo_list.string_list.remove_at(id+1)
		refresh_list.emit()
		task_counter += 1


func check_for_gameover():
	if task_counter == todo_list.string_list.size():
		$audio.stream = load("res://tyler98/sfx/error.mp3")
		$audio.play()
		await $audio.finished
		drop_priority_window()
		$bluescreen.visible = true
		gameover = true
