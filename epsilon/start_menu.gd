extends Control

@onready var anim_player = $anim_player
@onready var next_scene = "res://epsilon/epsilon.tscn"
@onready var prev_scene = "res://epsilon/epsilon.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	anim_player.play("pulse")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("start"):
		get_tree().change_scene_to_file(next_scene)
	if Input.is_action_pressed("go_back"):
		get_tree().change_scene_to_file(prev_scene)
