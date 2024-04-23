extends Node2D

enum players {PL1, PL2, PL3, PL4}
var fight_time: bool = true
var current_round : int
var max_rounds: int = 10
var knocked_out_mons: int = 0

@export var fight_length = 11
@export var upgrade_length = 6
@onready var upgrade_menu = $upgrade_ui
@onready var countdown_label = $countdown_ui/margin/seperator/label
@onready var countdown_nums = $countdown_ui/margin/seperator/countdown
@onready var round_timer = $round_timer
@onready var command_ui = $command_ui

const STATE = preload("res://tylermon/mon.gd")


func _ready():
	round_timer.start(fight_length)
	command_ui.visible = true
	upgrade_menu.visible = false
	var mons = get_tree().get_nodes_in_group("mons")
	for mon in mons:
		mon.connect("knocked_out", _add_knocked_out_mon)


func _process(delta):
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
		knocked_out_mons = 0
		round_timer.start(upgrade_length)
		upgrade_menu.visible = true
		command_ui.visible = false
		fight_time = false
		get_tree().call_group("upgrade_menus", "switch_upgrade_time", fight_time)
		get_tree().call_group("mons", "switch_round_modes", fight_time)
		countdown_label.text = "Add 3 points to stats:"
	else:
		round_timer.start(fight_length)
		upgrade_menu.visible = false
		command_ui.visible = true
		fight_time = true
		get_tree().call_group("mons", "switch_round_modes", fight_time)
		get_tree().call_group("upgrade_menus", "switch_upgrade_time", fight_time)
		countdown_label.text = "Round ends in:"
		current_round += 1


func check_for_winners_during_fight():
	if knocked_out_mons == 3:
		var mons = get_tree().get_nodes_in_group("mons")
		for mon in mons:
			if mon.current_state != STATE.State.KNOCKED_OUT:
				var player = mon.get_parent()
				player.wins += 1
				print(player.name, " wins")
			if mon.current_state == STATE.State.KNOCKED_OUT:
				var player = mon.get_parent()
				player.losses += 1
				print(player.name, " loses")
		round_timer.stop()
		_on_round_timer_timeout()


	# if there is only one mon not knocked out before the time is up, give them one win
	# and the others get 1 loss
	# if time is up, which mon has the highest current health, give them one win
	# and the others one loss
	# if it is a tie, tieing mons all get a win, the others get a loss


func check_for_game_end():
	if current_round == max_rounds:
		pass

func _add_knocked_out_mon():
	print("mon knocked out!")
	knocked_out_mons += 1
