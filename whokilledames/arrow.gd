extends Sprite2D
class_name Arrow


func _ready():
	pass # Replace with function body.


func _process(delta):
	var areas = $area.get_overlapping_areas()
	material.set_shader_parameter("line_thickness", 0)
	if areas.size():
		material.set_shader_parameter("line_thickness", 2)
