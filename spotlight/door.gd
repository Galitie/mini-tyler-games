extends AnimatedSprite2D
class_name Door

func Open():
	play("open")
	$area/shape.set_deferred("disabled", false)
