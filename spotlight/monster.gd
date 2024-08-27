extends Sprite2D

var target = null

var exposed: bool = false

func _ready() -> void:
	#$animation_player.play("quake", -1.0, 7)
	target = get_parent().get_node("player")

func _process(delta: float) -> void:
	var exposure_areas = $exposure.get_overlapping_areas()
	if exposure_areas.size():
		exposed = true
	else:
		exposed = false
	
	if !exposed:
		if target.is_on_floor():
			global_position.y = target.global_position.y + -50
		global_position.x = target.global_position.x + -60
