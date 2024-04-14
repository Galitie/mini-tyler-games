extends Control

@onready var anim_player = $anim_player

# Called when the node enters the scene tree for the first time.
func _ready():
	anim_player.play("pulse")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
