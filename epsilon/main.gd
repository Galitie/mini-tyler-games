extends Node2D
@onready var timer = $timer
@onready var audio_player = $audio
@onready var anim_player = $animation
@onready var anim_player2 = $animation2
@onready var text_container = $text_container/text
@onready var left_portrait = $left_portrait
@onready var right_portrait = $right_portrait
@onready var snake = load("res://epsilon/portraits/snake.tscn")
@onready var otacon = load("res://epsilon/portraits/otacon.tscn")
@onready var alert_sound = load("res://epsilon/sound_effects/alert.mp3")
@onready var codec_ring = load("res://epsilon/sound_effects/codec_ring.mp3")
@onready var codec_close = load("res://epsilon/sound_effects/codec_close.mp3")
@onready var codec_open = load("res://epsilon/sound_effects/codec_open.mp3")
@onready var waiting_huh = load("res://epsilon/sound_effects/kept_you_waiting_huh.mp3")
@onready var love_bloom = load("res://epsilon/sound_effects/love_bloom.mp3")


func _ready():
	text_container.text= "" #reset textbox
	main()


func main():
	await add_char(otacon, snake, "both", codec_open)
	await char_speaks("right", "Kept you waiting, huh?", "talking", waiting_huh)
	await char_speaks("left", "Do you think love can bloom, even on a battlefield?", "yelling", love_bloom)
	await change_char(otacon, "right")
	await char_speaks("right", "This is just like one of my japanese animes!", "talking", null)
	await change_char(snake, "right")
	await char_speaks("right", "Damn you!", "talking", null)
	remove_char("both", codec_close)


func _process(delta):
	pass


func add_char(char, optional_char2, portrait_side, audio):
	var loaded_char = char.instantiate()
	var loaded_char2 = optional_char2.instantiate()
	if portrait_side == "left":
		anim_player.play("left_portrait_close")
		await anim_player.animation_finished
		left_portrait.add_child(loaded_char)
		anim_player.play("left_portrait_open")
		await anim_player.animation_finished
		
	if portrait_side == "right":
		anim_player.play("right_portrait_close")
		await anim_player.animation_finished
		right_portrait.add_child(loaded_char)
		anim_player.play("right_portrait_open")
		await anim_player.animation_finished
		
	if portrait_side == "both":
		anim_player.play("left_portrait_close")
		anim_player2.play("right_portrait_close")
		await anim_player.animation_finished and anim_player2.animation_finished
		left_portrait.add_child(loaded_char)
		right_portrait.add_child(loaded_char2)
		audio_player.stream = audio
		audio_player.play()
		anim_player.play("left_portrait_open")
		anim_player2.play("right_portrait_open")
		await anim_player.animation_finished and anim_player2.animation_finished
		await audio_player.finished
		await one_shot_timer(.5)


func char_speaks(portrait_side, text, animation, audio):
	if text != null:
		text_container.text = text
	if portrait_side == "left" and animation != null:
		left_portrait.get_child(0).play(animation)
	if portrait_side == "right" and animation != null:
		right_portrait.get_child(0).play(animation)
	if audio != null:
		audio_player.stream = audio
		audio_player.play()
		await audio_player.finished
	if portrait_side == "right":
		right_portrait.get_child(0).play("default")
	if portrait_side == "left":
		left_portrait.get_child(0).play("default")
	if audio == null:
		await one_shot_timer(1)
	await one_shot_timer(0.5)


func change_char(new_char, portrait_side):
	var loaded_char = new_char.instantiate()
	if portrait_side == "left":
		var current_portrait = left_portrait.get_child(0)
		anim_player.play("left_portrait_close")
		await anim_player.animation_finished
		current_portrait.get_child(0).queue_free()
		left_portrait.add_child(loaded_char)
		anim_player.play("left_portrait_open")
		await anim_player.animation_finished
	
	if portrait_side == "right":
		anim_player.play("right_portrait_close")
		await anim_player.animation_finished
		right_portrait.get_child(0).queue_free()
		right_portrait.add_child(loaded_char)
		anim_player.play("right_portrait_open")
		await anim_player.animation_finished


func remove_char(portrait_side, audio):
	if portrait_side == "left":
		anim_player.play("left_portrait_close")
		await anim_player.animation_finished
		left_portrait.get_child(0).queue_free()
	
	if portrait_side == "right":
		anim_player.play("right_portrait_close")
		await anim_player.animation_finished
		right_portrait.get_child(0).queue_free()
	
	if portrait_side == "both":
		audio_player.stream = audio
		audio_player.play()
		anim_player.play("right_portrait_close")
		anim_player2.play("left_portrait_close")
		text_container.text = ""
		await anim_player.animation_finished and anim_player2.animation_finished
		right_portrait.get_child(0).queue_free()
		left_portrait.get_child(0).queue_free()


func one_shot_timer(seconds):
	timer.wait_time = seconds
	timer.start()
	await timer.timeout
