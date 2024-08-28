extends Node2D

var escaped_players: int = 0

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	
	for player in get_tree().get_nodes_in_group("players"):
		player.got_key.connect(_got_key)
		player.escaped.connect(_player_escaped)
		
func _got_key() -> void:
	$door.Open()

func _player_escaped() -> void:
	escaped_players += 1
	if escaped_players >= 4:
		await get_tree().create_timer(1.0).timeout
		await Globals.FadeIn()
		Globals.GoToMainMenu()
