extends Sprite3D

@export var sine_progress: float = 0
var amp: float = 0.2
var period: float = 10.0

var selected: bool = false

func _process(delta: float) -> void:
	sine_progress += delta * period
	sine_progress = fmod(sine_progress, 2 * PI)
	
	if !selected:
		global_position.y = SineWave()

func SineWave() -> float:
	return amp * sin(sine_progress)
