extends Node2D

var fight_time: bool
var current_round : int = 1
var knocked_out_mons: int = 0
var upgrades_counter: int = 0
var start_menu_time = true
var victory = load("res://tylermon/sfx/victory.mp3")

@export var fight_length: int
@export var upgrade_length: int
@export var max_rounds: int

@onready var audio_player = $audio
@onready var upgrade_menu = $upgrade_ui
@onready var countdown_label = $countdown_ui/margin/seperator/label
@onready var countdown_nums = $countdown_ui/margin/seperator/countdown
@onready var round_timer = $round_timer
@onready var transition_timer = $transition_timer
@onready var command_ui = $command_ui
@onready var customization_buttons = get_tree().get_nodes_in_group("customizer")
@onready var mons = get_tree().get_nodes_in_group("mons")
@onready var upgrade_menus = get_tree().get_nodes_in_group("upgrade_menus")


const STATE = preload("res://tylermon/mon.gd")

signal winners(winner_nodes : Array)
signal final_winners(winner_nodes : Array)
signal clear_winners
signal change_background


func _ready():
	$music.playing = true
	for menus in customization_buttons:
		menus.visible = true
	for mon in mons:
		mon.connect("knocked_out", _add_knocked_out_mon)
	for upgrade in upgrade_menus:
		upgrade.connect("upgrades_finished", end_upgrades_early)
	get_tree().get_root().get_child(2).get_node("Arena").get_node("backgrounds").get_node("margin").get_node("upgrade").visible = false	
	countdown_nums.text = "Customize Mon - press START when all players are ready!"


func start_game():
	start_menu_time = false
	for mon in mons:
		mon.hp_bar.visible = true
	for menus in customization_buttons:
		menus.queue_free()
	fight_time = true
	countdown_label.text = "Round ends: "
	$round_ui/margin/seperator/label.text = "Round: " + str(current_round) + "/" + str(max_rounds)
	$upgrade_ui/margin/GridContainer/upgrade_pos/upgrade_menu/player0/mon1/customizer.set_process(false)
	$upgrade_ui/margin/GridContainer/upgrade_pos2/upgrade_menu2/player1/mon2/customizer2.set_process(false)
	$upgrade_ui/margin/GridContainer/upgrade_pos4/upgrade_menu3/player2/mon3/customizer3.set_process(false)
	$upgrade_ui/margin/GridContainer/upgrade_pos3/upgrade_menu4/player3/mon4/customizer4.set_process(false)
	round_timer.start(fight_length)
	call_and_switch_modes()


func _physics_process(_delta):
	if Input.is_action_just_pressed("start") and start_menu_time == true:
		start_game()
	if start_menu_time == false:
		countdown_nums.text = "%02d" % time_left()
	if round_timer.time_left < 5 && start_menu_time == false:
		countdown_nums.set("theme_override_colors/font_color", Color("ff0000"))
	else:
		countdown_nums.set("theme_override_colors/font_color", Color("000000"))
	if fight_time:
		check_for_winners_during_fight()


func time_left():
	var time_left = round_timer.time_left
	var second = int(time_left) % 60
	return second


func _on_round_timer_timeout():
	if fight_time:
		fight_time = false
		upgrades_counter = 0
		var winners = get_end_of_round_winner()
		audio_player.stream = victory
		audio_player.play()
		var game_end = await check_for_game_end()
		if game_end:
			Globals.tylermon_played = true
			await Globals.FadeIn()
			Globals.GoToMainMenu()
			return
		call_and_pause()
		await show_transition("round_winners", winners, 5)
		call_and_switch_modes()
		upgrade_menu.visible = true
		#command_ui.visible = false
		knocked_out_mons = 0
		countdown_label.text = "Add 3 points to stats: "
		round_timer.stop()
		get_tree().get_root().get_child(2).get_node("Arena").get_node("backgrounds").get_node("margin").get_node("upgrade").visible = true
	else:
		fight_time = true
		current_round += 1
		upgrade_menu.visible = false
		get_tree().get_root().get_child(2).get_node("Arena").get_node("backgrounds").get_node("margin").get_node("upgrade").visible = false
		#command_ui.visible = true
		call_and_switch_modes()
		countdown_label.text = "Round ends:" 
		$round_ui/margin/seperator/label.text = "Round: " + str(current_round) + "/" + str(max_rounds)
		round_timer.start(fight_length)


func check_for_winners_during_fight():
	if knocked_out_mons == 3:
		round_timer.stop()
		_on_round_timer_timeout()


func get_end_of_round_winner():
	var mons = get_tree().get_nodes_in_group("mons")
	var highest_health_mon = null
	var winners = []
	for mon in mons:
		if highest_health_mon == null:
			highest_health_mon = mon
		if highest_health_mon.health <= mon.health:
			highest_health_mon = mon
	for mon in mons:
		if mon.health == highest_health_mon.health:
			var player = mon.get_parent()
			player.wins += 5
			winners.append(player)
	
	var players = get_tree().get_nodes_in_group("player")
	
	var losers = []
	
	for player in players:
		if !winners.has(player):
			losers.append(player)
	
	for loser in losers:
		if winners.size() == 3:
			loser.wins += 3
		if winners.size() == 2:
			loser.wins += 2
	
	return winners


func check_for_game_end() -> bool:
	if current_round == max_rounds:
		var winning_players = []
		var highest_wins
		var players = get_tree().get_nodes_in_group("player")
		for player in players:
			if highest_wins == null:
				highest_wins = player.wins 
			elif highest_wins <= player.wins:
				highest_wins = player.wins
		for player in players:
			if player.wins == highest_wins:
				winning_players.append(player)
		call_and_pause()
		await show_transition("final_winner", winning_players, 10)
		return true
	return false

func _add_knocked_out_mon():
	knocked_out_mons += 1


func call_and_switch_modes():
	get_tree().call_group("mons", "switch_round_modes", fight_time)
	get_tree().call_group("upgrade_menus", "switch_upgrade_time", fight_time)
	get_tree().call_group("player", "switch_modes", fight_time)


func call_and_pause():
	get_tree().call_group("mons", "pause")


func show_transition(type, content, timer_amount):
	if type == "round_winners":
		$wait_timer.start(2.5)
		await $wait_timer.timeout
		emit_signal("winners", content)
		transition_timer.start(timer_amount)
		$transition_ui.visible = true
		await transition_timer.timeout
		$transition_ui.visible = false
		emit_signal("clear_winners")
	if type == "final_winner":
		$wait_timer.start(2.5)
		await $wait_timer.timeout
		transition_timer.start(timer_amount)
		emit_signal("final_winners", content)
		$transition_ui.visible = true
		await transition_timer.timeout


func end_upgrades_early():
	upgrades_counter += 1
	if upgrades_counter == 4:
		round_timer.start(4)
