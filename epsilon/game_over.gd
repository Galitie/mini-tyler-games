extends VideoStreamPlayer

@onready var game_over = preload("res://epsilon/backgrounds/game_over.ogv")
@onready var continue_game = preload("res://epsilon/backgrounds/continue.ogv")

var random_vo: Array = [
	preload("res://epsilon/vo/2_grah.mp3"),
	preload("res://epsilon/vo/4_liquid.mp3"),
	preload("res://epsilon/vo/2_feel.mp3") #TOO LOUD. Need to balance out all vo lines at 0 db
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
	await get_tree().create_timer(0.6).timeout
	$vo.stream = random_vo.pick_random()
	$vo.play()
	await get_tree().create_timer(2.5).timeout
	paused = true
	
func Continue() -> void:
	stream = continue_game
	paused = false
	play()
	$gunshot.play()
	await finished
