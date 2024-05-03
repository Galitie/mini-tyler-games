extends Node2D

var fight_time: bool
var current_round : int = 1
var knocked_out_mons: int = 0
var upgrades_counter: int = 0

@export var fight_length: int
@export var upgrade_length: int
@export var max_rounds: int

@onready var upgrade_menu = $upgrade_ui
@onready var countdown_label = $countdown_ui/margin/seperator/label
@onready var countdown_nums = $countdown_ui/margin/seperator/countdown
@onready var round_timer = $round_timer
@onready var transition_timer = $transition_timer
@onready var command_ui = $command_ui


const STATE = preload("res://tylermon/mon.gd")

signal winners(winner_nodes : Array)
signal final_winners(winner_nodes : Array)
signal clear_winners


func _ready():
	fight_time = true
	round_timer.start(fight_length)
	call_and_switch_modes()
	var mons = get_tree().get_nodes_in_group("mons")
	for mon in mons:
		mon.connect("knocked_out", _add_knocked_out_mon)
	var upgrade_menus = get_tree().get_nodes_in_group("upgrade_menus")
	for upgrade in upgrade_menus:
		upgrade.connect("upgrades_finished", end_upgrades_early)


func _process(_delta):
	countdown_nums.text = "%02d" % time_left()
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
		call_and_switch_modes()
		await check_for_game_end()
		upgrade_menu.visible = true
		command_ui.visible = false
		await show_transition("round_winners", winners, 5)
		knocked_out_mons = 0
		countdown_label.text = "Add 3 points to stats:"
		round_timer.start(upgrade_length)
	else:
		fight_time = true
		current_round += 1
		upgrade_menu.visible = false
		command_ui.visible = true
		call_and_switch_modes()
		countdown_label.text = "Round ends in:"
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
		if mon.health != highest_health_mon.health:
			var player = mon.get_parent()
			player.losses += 1
		else:
			var player = mon.get_parent()
			player.wins += 1
			winners.append(player)
	return winners


func check_for_game_end():
	if current_round == max_rounds:
		var winning_players_before_totals = []
		var winning_players = []
		var highest_wins
		var highest_total
		var players = get_tree().get_nodes_in_group("player")
		for player in players:
			if highest_wins == null:
				highest_wins = player.wins 
			if highest_wins <= player.wins:
				highest_wins = player.wins
		for player in players:
			if player.wins == highest_wins:
				winning_players_before_totals.append(player)
		if winning_players_before_totals.size() > 1:
			for player in winning_players_before_totals:
				if highest_total == null:
					highest_total = (player.wins - player.losses)
				if highest_total <= (player.wins - player.losses):
					highest_total = (player.wins - player.losses)
			for player in players:
				if (player.wins - player.losses) == highest_total:
					winning_players.append(player)
			await show_transition("final_winner", winning_players, 100)
		else:
			await show_transition("final_winner", winning_players_before_totals, 100)


func _add_knocked_out_mon():
	knocked_out_mons += 1


func call_and_switch_modes():
	get_tree().call_group("mons", "switch_round_modes", fight_time)
	get_tree().call_group("upgrade_menus", "switch_upgrade_time", fight_time)
	get_tree().call_group("player", "switch_modes", fight_time)


func show_transition(type, content, timer_amount):
	if type == "round_winners":
		transition_timer.start(timer_amount)
		emit_signal("winners", content)
		$transition_ui.visible = true
		await transition_timer.timeout
		$transition_ui.visible = false
		emit_signal("clear_winners")
	if type == "final_winner":
		transition_timer.start(timer_amount)
		emit_signal("final_winners", content)
		$transition_ui.visible = true
		await transition_timer.timeout


func end_upgrades_early():
	upgrades_counter += 1
	if upgrades_counter == 4 and round_timer.time_left > 4:
		round_timer.stop()
		round_timer.start(4)
