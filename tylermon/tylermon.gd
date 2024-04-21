extends Node2D

var round = 0
enum players {PL1, PL2, PL3, PL4}
var fight_time = true
var fight_length = 11
var upgrade_length = 6

@onready var upgrade_menu = $upgrade_ui
@onready var countdown_label = $countdown_ui/margin/seperator/label
@onready var countdown_nums = $countdown_ui/margin/seperator/countdown
@onready var round_timer = $round_timer
@onready var command_ui = $command_ui



func _ready():
	round_timer.start(fight_length)
	command_ui.visible = true
	upgrade_menu.visible = false


func _process(delta):
	countdown_nums.text = "%02d" % time_left()


func time_left():
	var time_left = round_timer.time_left
	var second = int(time_left) % 60
	return second


func _on_round_timer_timeout():
	if fight_time:
		round_timer.start(upgrade_length)
		upgrade_menu.visible = true
		command_ui.visible = false
		fight_time = false
		get_tree().call_group("upgrade_menus", "switch_upgrade_time", fight_time)
		get_tree().call_group("mons", "switch_round_modes", fight_time)
		countdown_label.text = "Upgrade time left:"
	else:
		round_timer.start(fight_length)
		upgrade_menu.visible = false
		command_ui.visible = true
		fight_time = true
		get_tree().call_group("mons", "switch_round_modes", fight_time)
		get_tree().call_group("upgrade_menus", "switch_upgrade_time", fight_time)
		countdown_label.text = "Round ends in:"
