extends Camera2D

func _ready() -> void:
	$ui.visible = true
	RenderingServer.set_default_clear_color(Color("102830"))
	
func _process(delta: float) -> void:
	var snake_total_position: Vector2 = Vector2.ZERO
	var snake_positions: int = 0
	for snake in get_tree().get_nodes_in_group("snakes"):
		if snake.state != Snake.SnakeState.DEAD:
			snake_total_position += snake.global_position
			snake_positions += 1
	snake_total_position = snake_total_position / snake_positions
	if snake_positions > 0:
		global_position = snake_total_position
