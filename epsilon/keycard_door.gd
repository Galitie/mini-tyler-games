extends StaticBody2D
@export var door_level: int
var locked = true
var opened = false
@export var color: Color

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
		

