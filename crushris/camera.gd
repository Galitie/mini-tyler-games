extends Camera2D

@export var randomStrength: float = 15.0
@export var shakeFade: float = 3.0
var shaking: bool = false

var rng = RandomNumberGenerator.new()
var shake_strength: float = 0.0

func apply_shake():
	shaking = true
	shake_strength = randomStrength

func _process(delta):	
	if shake_strength > 0:
		shake_strength = lerp(shake_strength, 0.0, shakeFade * delta)
		offset = randomOffset()
	
	if shake_strength < .5:
		shaking = false

func randomOffset() -> Vector2:
	return Vector2(640 + rng.randf_range(-shake_strength, shake_strength), 360 + rng.randf_range(-shake_strength, shake_strength))
