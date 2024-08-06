extends StaticBody2D
@export var door_level: int
@export var color: Color
var locked = true
var opened = false
var locked_sfx = preload("res://epsilon/sound_effects/no_keycard.mp3")
var open_sfx = preload("res://epsilon/sound_effects/door_open.mp3")

func _ready():
	$sprite.material.set_shader_parameter("new", color)
	add_to_group("keycard door")
	$area2d.body_entered.connect(_body_entered)	


func _body_entered(body: Node2D) -> void:
	if locked == false && opened == false:
		$sprite.play("open")
		opened = true
		$collider.set_deferred("disabled", true)
		$area2d/collider.set_deferred("disabled", true)
		$sfx.stream = open_sfx
		$sfx.play()
	if locked == true:
		$sfx.stream = locked_sfx
		$sfx.play()

