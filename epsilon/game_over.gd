extends VideoStreamPlayer

@onready var game_over = preload("res://epsilon/backgrounds/game_over.ogv")
@onready var continue_game = preload("res://epsilon/backgrounds/continue.ogv")

var random_vo: Array = [
	preload("res://epsilon/vo/2_snake_annoyed.mp3"),
	preload("res://epsilon/vo/3_watch.mp3"),
	preload("res://epsilon/vo/2_friends.mp3"),
	preload("res://epsilon/vo/1_osha.mp3"),
	#preload("res://epsilon/vo/2_feel.mp3") TOO LOUD. Need to balance out all vo lines at 0 db
]

func GameOver() -> void:
	$argh.play()
	stream = game_over
	play()
	await get_tree().create_timer(1.0).timeout
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
