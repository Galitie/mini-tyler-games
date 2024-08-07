extends Node2D

@onready var timer = $timer
@onready var audio_player = $audio
@onready var left_audio = $left_audio
@onready var anim_player = $animation
@onready var text_container = $text_container/text
@onready var left_portrait = $left_portrait
@onready var right_portrait = $right_portrait
@onready var codec_background = $codec_background

@onready var codec_ring = load("res://epsilon/sound_effects/codec_ring.mp3")
@onready var portrait_close = load("res://epsilon/sound_effects/portrait_close.mp3")
@onready var portrait_open = load("res://epsilon/sound_effects/portrait_open.mp3")

var voice_lines: Dictionary = {}
var characters: Dictionary = {}

var interrupted: bool = false

func load_assets(file: FileAccess, dict: Dictionary, instantiate: bool = false) -> void:
	var line: String = file.get_line()
	while line != "end":
		var args: PackedStringArray = line.split(" ")
		var asset = load(args[0])
		if instantiate:
			dict[args[1]] = asset.instantiate()
		else:
			dict[args[1]] = asset
		line = file.get_line()

func _ready():
	text_container.text= "" #reset textbox
	
func play_file(file_path: String) -> void:
	var regex: RegEx = RegEx.new()
	regex.compile('"(.*?)"')
	
	await codec_anim("codec_open")
	var codec_file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	while !interrupted && !codec_file.eof_reached():
		var line: String = codec_file.get_line()
		var args: PackedStringArray = line.split(" ")
		match args[0]:
			"load":
				match args[1]:
					"vo":
						load_assets(codec_file, voice_lines)
					"char":
						load_assets(codec_file, characters, true)
			"port":
				await port(args)
			"msg":
				var results: PackedStringArray = regex.search(line).strings
				var text = results[0].replace('\"', " ").strip_edges()
				await char_speaks(args, voice_lines[args[3]], text)
			_:
				pass
	
	if interrupted:
		await port(["port", "remove", "1", "2"])
		interrupted = false
	await codec_anim("codec_close")
	
func codec_anim(animation):
	await one_shot_timer(.75)
	anim_player.play(animation)
	await anim_player.animation_finished

func port(args: PackedStringArray):
	var left: bool = false
	var right: bool = false
	
	var adding: bool = false
	if args[1] == "add":
		adding = true
		
	if args[2] != "NULL":
		left = true
	if args[3] != "NULL":
		right = true
			
	if left:
		left_portrait.get_node("anim_player").play("close", -1, 1.5)
	if right:
		right_portrait.get_node("anim_player").play("close", -1, 1.5)
	
	if !adding:
		audio_player.stream = portrait_close
		audio_player.play()
		
	if left:
		await left_portrait.get_node("anim_player").animation_finished
	elif right:
		await right_portrait.get_node("anim_player").animation_finished
	
	if left:
		if left_portrait.get_node("char").get_child_count() != 0:
			left_portrait.get_node("char").remove_child(left_portrait.get_node("char").get_child(0))
	if right:
		if right_portrait.get_node("char").get_child_count() != 0:
			right_portrait.get_node("char").remove_child(right_portrait.get_node("char").get_child(0))
	
	if adding:
		if left && !right:
			left_portrait.get_node("char").add_child(characters[args[2]])
		elif right && !left:
			right_portrait.get_node("char").add_child(characters[args[3]])
		else:
			left_portrait.get_node("char").add_child(characters[args[2]])
			right_portrait.get_node("char").add_child(characters[args[3]])
			
		if left:
			left_portrait.get_node("anim_player").play("open", -1, 1.5)
		if right:
			right_portrait.get_node("anim_player").play("open", -1, 1.5)
			
		audio_player.stream = portrait_open
		audio_player.play()
			
		if left:
			await left_portrait.get_node("anim_player").animation_finished
		elif right:
			await right_portrait.get_node("anim_player").animation_finished
		await one_shot_timer(.5)

func char_speaks(args: PackedStringArray, voice_line: AudioStream, text: String):
	text_container.text = text
	
	var audio: AudioStreamPlayer2D = null
	if args[1] == "left":
		left_portrait.get_node("char").get_child(0).play(args[2])
		audio = left_audio
	if args[1] == "right":
		right_portrait.get_node("char").get_child(0).play(args[2])
		# NOTE: Might get punished for this, but we're good for now
		audio = audio_player
		
	audio.stream = voice_line
	audio.play()
	await audio.finished
	text_container.text = ""

	if args[1] == "right":
		right_portrait.get_node("char").get_child(0).play("default")
	if args[1] == "left":
		left_portrait.get_node("char").get_child(0).play("default")
		
	await one_shot_timer(.5)

func one_shot_timer(seconds):
	timer.wait_time = seconds
	timer.start()
	await timer.timeout
