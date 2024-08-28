extends Sprite2D
class_name Key

enum Dimension { CYAN, YELLOW, MAGENTA, WHITE}

@export var dimension: Dimension = Dimension.WHITE

func _ready() -> void:
	match dimension:
		Dimension.CYAN:
			modulate = Color.CYAN
			# Layer 5
			$area.collision_layer = 0b00000000_00000000_00000000_00010000
		Dimension.YELLOW:
			modulate = Color.YELLOW
			# Layer 6
			$area.collision_layer = 0b00000000_00000000_00000000_00100000
		Dimension.MAGENTA:
			modulate = Color.MAGENTA
			# Layer 7
			$area.collision_layer = 0b00000000_00000000_00000000_01000000
		Dimension.WHITE:
			modulate = Color.WHITE
			# Layer 9
			$area.collision_layer = 0b00000000_00000000_00000001_00000000
