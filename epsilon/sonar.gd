extends Area2D

var cooldown: float = 0.0
var cooldown_length: float = 5.0

func _ready() -> void:
	$anim_player.animation_finished.connect(_animation_finished)

func _process(delta) -> void:
	if cooldown > 0.0:
		cooldown -= 1.0 * delta
	if cooldown < 0.0:
		cooldown = 0.0
		
	var mines: Array = $detection.get_overlapping_areas()
	if cooldown == 0.0 && mines.size() > 0:
		cooldown = cooldown_length
		$anim_player.play("ping")
		set_deferred("monitorable", true)
		$sfx.play()

func _animation_finished(anim_name: String) -> void:
	$anim_player.play("RESET")
	set_deferred("monitorable", false)
