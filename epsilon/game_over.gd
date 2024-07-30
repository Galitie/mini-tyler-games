extends VideoStreamPlayer

@onready var game_over = preload("res://epsilon/backgrounds/game_over.ogv")
@onready var continue_game = preload("res://epsilon/backgrounds/continue.ogv")
@onready var starting_counter: int = random_vo.size()
@onready var counter:int = 0

var random_vo: Array = [
	preload("res://epsilon/vo/game_over_1.mp3"),
	preload("res://epsilon/vo/game_over_2.mp3"),
	preload("res://epsilon/vo/game_over_3.mp3"), #TOO LOUD. Need to balance out all vo lines at 0 db
]

func GameOverDeath() -> void:
	$argh.play()
	await get_tree().create_timer(4.0).timeout

func GameOver() -> void:
	stream = game_over
	play()
	$text_sfx.play()
	await get_tree().create_timer(3.0).timeout
	$codec_ring.play()
	await get_tree().create_timer(1.8).timeout
	if counter < starting_counter - 1:
		counter += 1
	else:
		counter = 0
	$vo.stream = random_vo[counter - 1]
	$vo.play()
	await get_tree().create_timer(1.5).timeout
	paused = true
	
func Continue() -> void:
	stream = continue_game
	paused = false
	play()
	$gunshot.play()
	await finished
