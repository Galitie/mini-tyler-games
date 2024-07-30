extends Area2D

var timer_progress: float = 0.0
var timer_length: float = 4.0
	
func _process(delta) -> void:
	timer_progress += 1.0 * delta
	if timer_progress > timer_length:
		timer_progress = 0.0
		timeout()

func timeout() -> void:
	$anim_player.play("ping")
	$sfx.play()
