extends Node2D

var escaped_players: int = 0

var current_player = null
var player_idx: int = 0

var current_map = null

var map_paths: Array = [
	"res://spotlight/maps/map0.tscn",
	"res://spotlight/maps/map1.tscn",
	"res://spotlight/maps/map2.tscn",
]
var map_idx: int = 0

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	
	for player in get_tree().get_nodes_in_group("players"):
		player.got_key.connect(_got_key)
		player.escaped.connect(_player_escaped)
		
	current_player = get_tree().get_nodes_in_group("players")[player_idx]
	
	ChangeMap(map_idx)
	
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
	current_map.get_node("door").Open()

func _player_escaped() -> void:
	escaped_players += 1
	if escaped_players >= 4:
		await get_tree().create_timer(1.0).timeout
		map_idx += 1
		if map_idx <= map_paths.size() - 1:
			escaped_players = 0
			ChangeMap(map_idx)
		else:
			Globals.spotlight_played = true
			await Globals.FadeIn()
			Globals.GoToMainMenu()

func ChangeMap(idx: int) -> void:
	if current_map != null:
		remove_child(current_map)
		current_map.queue_free()
		
	current_map = load(map_paths[idx]).instantiate()
	add_child(current_map)
	for i in range(current_map.get_node("spawns").get_child_count()):
		var spawn_loc = current_map.get_node("spawns").get_child(i).global_position
		get_tree().get_nodes_in_group("players")[i].global_position = spawn_loc
	
	for player in get_tree().get_nodes_in_group("players"):
		player.Spawn(player.global_position)
		player.has_escaped = false
