extends Node2D

var fight_time: bool
var current_round : int = 1
var max_rounds: int = 10
var knocked_out_mons: int = 0

@export var fight_length: int
@export var upgrade_length: int
@onready var upgrade_menu = $upgrade_ui
@onready var countdown_label = $countdown_ui/margin/seperator/label
@onready var countdown_nums = $countdown_ui/margin/seperator/countdown
@onready var round_timer = $round_timer
@onready var command_ui = $command_ui
@onready var wins_ui = $wins_ui
@onready var player1_win_label = $wins_ui/margin/box/hbox/wins
@onready var player2_win_label = $wins_ui/margin/box/hbox2/wins
@onready var player3_win_label = $wins_ui/margin/box/hbox3/wins
@onready var player4_win_label = $wins_ui/margin/box/hbox4/wins


const STATE = preload("res://tylermon/mon.gd")


func _ready():
	fight_time = true
	round_timer.start(fight_length)
	call_and_switch_modes()
	var mons = get_tree().get_nodes_in_group("mons")
	for mon in mons:
		mon.connect("knocked_out", _add_knocked_out_mon)


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
		check_for_game_end()
		get_end_of_round_winner()
		update_player_wins_losses_labels()
		knocked_out_mons = 0
		round_timer.start(upgrade_length)
		upgrade_menu.visible = true
		command_ui.visible = false
		fight_time = false
		call_and_switch_modes()
		wins_ui.visible = true
		countdown_label.text = "Add 3 points to stats:"
	else:
		round_timer.start(fight_length)
		upgrade_menu.visible = false
		command_ui.visible = true
		wins_ui.visible = false
		fight_time = true
		call_and_switch_modes()
		countdown_label.text = "Round ends in:"
		current_round += 1


func check_for_winners_during_fight():
	if knocked_out_mons == 3:
		var mons = get_tree().get_nodes_in_group("mons")
		for mon in mons:
			if mon.current_state != STATE.State.KNOCKED_OUT:
				var player = mon.get_parent()
				player.wins += 1
			if mon.current_state == STATE.State.KNOCKED_OUT:
				var player = mon.get_parent()
				player.losses += 1
		round_timer.stop()
		_on_round_timer_timeout()

# right now it's mon's with most health including ties...do I want to count kills?
func get_end_of_round_winner():
	var mons = get_tree().get_nodes_in_group("mons")
	var highest_health_mon = null
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


func update_player_wins_losses_labels():
	var players = get_tree().get_nodes_in_group("player")
	for player in players:
		if player.name == "player0":
			player1_win_label.text = str(player.wins)
		if player.name == "player1":
			player2_win_label.text = str(player.wins)
		if player.name == "player2":
			player3_win_label.text = str(player.wins)
		if player.name == "player3":
			player4_win_label.text = str(player.wins)
								


func check_for_game_end():
	if current_round == max_rounds:
		pass


func _add_knocked_out_mon():
	knocked_out_mons += 1


func call_and_switch_modes():
	get_tree().call_group("mons", "switch_round_modes", fight_time)
	get_tree().call_group("upgrade_menus", "switch_upgrade_time", fight_time)
	get_tree().call_group("player", "switch_modes", fight_time)
