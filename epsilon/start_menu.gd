extends Control

@onready var anim_player = $anim_player
@onready var scene = "res://epsilon/epsilon.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	anim_player.play("pulse")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("start"):
		get_tree().change_scene_to_file(scene)
