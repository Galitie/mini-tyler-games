extends AnimatedSprite2D
class_name Door

func _ready() -> void:
	add_to_group("doors")

func Open() -> void:
	play("open")
	$area/shape.set_deferred("disabled", false)
