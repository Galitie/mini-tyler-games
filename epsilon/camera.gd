extends Camera2D

func _ready() -> void:
	$ui.visible = true
	RenderingServer.set_default_clear_color(Color("102830"))
	global_position = GetDestination()
	# NOTE: Have to call it twice to work, Spaghodot
	reset_smoothing()
	reset_smoothing()
	
func _process(delta: float) -> void:
	global_position = GetDestination()
	
func GetDestination() -> Vector2:
	var snake_total_position: Vector2 = Vector2.ZERO
	var snake_positions: int = 0
	for snake in get_tree().get_nodes_in_group("snakes"):
		if snake.state != Snake.SnakeState.DEAD:
			snake_total_position += snake.global_position
			snake_positions += 1
	snake_total_position = snake_total_position / snake_positions
	if snake_positions > 0:
		return snake_total_position
	return global_position
