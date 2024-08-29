extends Node2D

var escaped_players: int = 0

var current_player = null
var player_idx: int = 0

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	
	for player in get_tree().get_nodes_in_group("players"):
		player.got_key.connect(_got_key)
		player.escaped.connect(_player_escaped)
		
	current_player = get_tree().get_nodes_in_group("players")[player_idx]
		
func _process(delta: float) -> void:
	if Controller.IsControllerButtonJustPressed(0, JOY_BUTTON_RIGHT_SHOULDER):
		player_idx += 1
		if player_idx > get_tree().get_nodes_in_group("players").size() - 1:
			player_idx = 0
		current_player.debug_port = -1
		current_player = get_tree().get_nodes_in_group("players")[player_idx]
		if !current_player.has_escaped:
			current_player.Honk()
		current_player.debug_port = 0
		
func _got_key() -> void:
	$door.Open()

func _player_escaped() -> void:
	escaped_players += 1
	if escaped_players >= 4:
		await get_tree().create_timer(1.0).timeout
		await Globals.FadeIn()
		Globals.GoToMainMenu()
		return
