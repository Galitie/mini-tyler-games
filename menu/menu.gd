extends Node3D

@onready var camera: Camera3D = $camera
@onready var timer: Timer = $timer
@onready var spin_timer: Timer = $spin_timer
@onready var title: Node3D = $title
@onready var logo: Node3D = $logo_origin
@onready var projector: MeshInstance3D = $projector

var move_right_sfx = preload("res://menu/move_right.wav")
var move_left_sfx = preload("res://menu/move_left.wav")
var select_sfx = preload("res://menu/select.wav")
var locked_sfx = preload("res://menu/locked.wav")

var selecting: bool = false
var spinning: bool = false

var transition_speed: float = 7.0
var spin_speed: float = 6.0

var final_position: Vector3 = Vector3(-14, 10, -14)

var last_thumbnail_position = Vector3.ZERO
var thumbnail_idx: int = 0
var can_select: bool = false

var thumbnails: Array = [
	load("res://menu/crushtris_thumbnail.png"),
	load("res://menu/epsilon_thumbnail.png"),
	load("res://menu/crushtris_thumbnail.png")
]

var thumbnail_titles: Array = [
	"CRUSHTRIS: THE RECKONING",
	"TYLERMON",
	"SPOTLIGHTS",
	"WHO KILLED AMES?",
	"METAL GEAR SOLID: EPSILON"
]

var thumbnail_descs: Array = [
	"It's Tetris®, but with more pain and violence! Try to crush your friends in this absolutely original new game!\n\n2-4 Players",
	"You like Digimon®? No?! Well, too bad! Customize your Tylermon™ and watch it fight to the death! Yeah!\n\n2-4 Players",
	"Three guys love to stand out, but one of them prefers to blend in. You'll need them all to solve these puzzles!\n\n4 Players",
	"Who done it? And how? A point and click murder mystery that will take you way back to the good ole' days! \n\n4 Players",
	"Would you give your life? Not for honor, but for you? Now you can do that, but with three other people!\n\n1-4 Players"
]

var thumbnail_scene_paths: Array = [
	"res://crushris/crushris.tscn",
	"res://tylermon/title.tscn",
	"res://spotlight/spotlight.tscn",
	"res://whokilledames/test.tscn",
	"res://epsilon/start_menu.tscn"
]

func _ready() -> void:
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	timer.timeout.connect(_timeout)
	spin_timer.timeout.connect(_spin_timeout)
	$music.play()
	
	if Globals.crushtris_played && Globals.tylermon_played:
		Globals.metalgear_unlocked = true
		$thumbnails/metalgear.texture = load("res://menu/epsilon_thumbnail.png")
		$thumbnails/metalgear.vframes = 1
		$thumbnails/metalgear.hframes = 1
	else:
		$thumbnails/metalgear.get_node("AnimationPlayer").play("static")
	
	if Globals.intro_played:
		$music.seek(4)
		selecting = true
		$camera.global_position = final_position + Vector3(-6.6, 0, -2.5)
		$camera.global_rotation = Vector3(deg_to_rad(-20.4), deg_to_rad(-139.4), 0)
		
		for thumbnail in $thumbnails.get_children():
			thumbnail.modulate = Color(1, 1, 1, 1)
		
		title.get_node("animator").play("skooch_in")
		title.get_node("animator").seek(1, true)
	else:
		$timer.start()
	
	await Globals.FadeOut()
		
	if Globals.intro_played:
		thumbnail_idx = Globals.last_thumbnail_idx
		await get_tree().create_timer(1.0).timeout
		$sfx.stream = move_right_sfx
		$sfx.play()
		await SelectThumbnail($thumbnails.get_child(thumbnail_idx), thumbnail_idx)
		can_select = true
		
	Globals.intro_played = true
	
func _process(delta: float) -> void:
	if selecting:
		projector.rotate(Vector3.UP, 0.1 * 0.1 * delta)
		projector.rotate(Vector3.RIGHT, 0.2 * 0.1 * delta)
		projector.rotate(-Vector3.FORWARD, 0.3 * 0.1 * delta)
		
	if spinning:
		logo.rotate(Vector3.UP, spin_speed * delta)
		camera.transform.origin = camera.transform.origin.move_toward(final_position, transition_speed * delta)
		camera.look_at(Vector3(0, 2, 0), Vector3.UP)
	else:
		logo.basis = logo.basis.slerp(Basis(), 5.5 * delta)
		
	if can_select:
		if Controller.GetLeftStick(0).x < 0:
				can_select = false
				$sfx.stream = move_left_sfx
				$sfx.play()
				await DeselectThumbnail($thumbnails.get_child(thumbnail_idx))
				thumbnail_idx -= 1
				if thumbnail_idx < 0:
					thumbnail_idx = $thumbnails.get_children().size() - 1
				await SelectThumbnail($thumbnails.get_child(thumbnail_idx), thumbnail_idx)
				can_select = true
		elif Controller.GetLeftStick(0).x > 0:
				can_select = false
				$sfx.stream = move_right_sfx
				$sfx.play()
				await DeselectThumbnail($thumbnails.get_child(thumbnail_idx))
				thumbnail_idx += 1
				if thumbnail_idx > $thumbnails.get_children().size() - 1:
					thumbnail_idx = 0
				await SelectThumbnail($thumbnails.get_child(thumbnail_idx), thumbnail_idx)
				can_select = true
				
		if Controller.IsControllerButtonJustPressed(0, JOY_BUTTON_A):
			if thumbnail_idx == $thumbnails.get_children().size() - 1 && !Globals.metalgear_unlocked:
				if $sfx.stream != locked_sfx || !$sfx.playing:
					$sfx.stream = locked_sfx
					$sfx.play()
				return
			can_select = false
			Globals.last_thumbnail_idx = thumbnail_idx
			$sfx.stream = select_sfx
			$sfx.play()
			await Globals.FadeIn()
			await $sfx.finished
			get_tree().change_scene_to_file(thumbnail_scene_paths[thumbnail_idx])
			await Globals.FadeOut()
			return
	
func _timeout() -> void:
	selecting = true
	spinning = true
	title.get_node("animator").play("skooch_out")
	spin_timer.start(1.9)

func _spin_timeout() -> void:
	spinning = false
	title.get_node("animator").play("skooch_in")
	await get_tree().create_timer(2.5).timeout
	var camera_tween = get_tree().create_tween()
	camera_tween.tween_property($camera, "global_position", final_position + Vector3(-6.6, 0, -2.5), 1.0).set_trans(Tween.TRANS_CUBIC)
	
	for thumbnail in $thumbnails.get_children():
		var alpha_tween = get_tree().create_tween()
		alpha_tween.tween_property(thumbnail, "modulate", Color(1, 1, 1, 1), 1.0).set_trans(Tween.TRANS_CUBIC)
	await get_tree().create_timer(2.0).timeout
	$sfx.stream = move_right_sfx
	$sfx.play()
	await SelectThumbnail($thumbnails.get_child(thumbnail_idx), thumbnail_idx)
	can_select = true

func SelectThumbnail(thumbnail: Sprite3D, idx: int) -> void:
	last_thumbnail_position = thumbnail.global_position
	var xform: Transform3D = Transform3D()
	xform = xform.scaled(Vector3(1.5, 1.5, 1.5))
	xform = xform.rotated(Vector3.UP, deg_to_rad(-140))
	xform.origin = Vector3(-9, 6, 0)
	var xform_tween = get_tree().create_tween()
	xform_tween.tween_property(thumbnail, "global_transform", xform, 0.25).set_trans(Tween.TRANS_CUBIC)
	await xform_tween.finished
	thumbnail.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	
	var desc_tween = get_tree().create_tween()
	if idx == $thumbnails.get_children().size() - 1 && !Globals.metalgear_unlocked:
		$Control/game_description.text = "[center][rainbow freq=0.2 sat=1 val=.8][wave amp=40.0 freq=-2 connected=1]" + "???" + "[/wave][/rainbow][/center]"
		$Control/game_description/text.text = "What a thrill..."
	else:
		$Control/game_description.text = "[center][rainbow freq=0.2 sat=1 val=.8][wave amp=40.0 freq=-2 connected=1]" + thumbnail_titles[idx] + "[/wave][/rainbow][/center]"
		$Control/game_description/text.text = thumbnail_descs[idx]
	desc_tween.tween_property($Control/game_description, "modulate", Color(1, 1, 1, 1), 0.25).set_trans(Tween.TRANS_CUBIC)

func DeselectThumbnail(thumbnail: Sprite3D) -> void:
	var desc_tween = get_tree().create_tween()
	desc_tween.tween_property($Control/game_description, "modulate", Color(1, 1, 1, 0), 0.25).set_trans(Tween.TRANS_CUBIC)
	
	thumbnail.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	var xform: Transform3D = Transform3D()
	xform = xform.scaled(Vector3(1.5, 1.5, 1.5))
	xform = xform.rotated(Vector3.RIGHT, deg_to_rad(-90)).rotated(Vector3.UP, deg_to_rad(-90))
	xform.origin = last_thumbnail_position
	var xform_tween = get_tree().create_tween()
	xform_tween.tween_property(thumbnail, "global_transform", xform, 0.25).set_trans(Tween.TRANS_CUBIC)
	await xform_tween.finished
