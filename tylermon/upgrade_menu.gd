extends Control
var mon
var player
var upgrade_time : bool = false
var points_to_spend : int = 3
var players_done_upgrading : int = 0
var current_focus

@onready var hp_stat = $margin/hbox/buttons/hbox/stat1
@onready var str_stat = $margin/hbox/buttons/hbox2/stat2
@onready var int_stat = $margin/hbox/buttons/hbox3/stat3
@onready var type_stat = $margin/hbox/buttons/hbox5/stat4
@onready var player_wins = $margin/hbox/buttons/hbox7/hbox6/wins/wins_num
@onready var player_losses = $margin/hbox/buttons/hbox7/hbox6/losses/losses_num
@onready var description = $margin/hbox/buttons/description

@onready var hp_button = $margin/hbox/buttons/hbox/hp
@onready var str_button = $margin/hbox/buttons/hbox2/str
@onready var int_button = $margin/hbox/buttons/hbox3/int
@onready var gamble_button = $margin/hbox/buttons/hbox7/gamble
@onready var type_button = $margin/hbox/buttons/hbox5/type
@onready var upgrade_buttons = [hp_button, str_button, int_button, gamble_button, type_button]


var hp_desc = "+1 max mon health"
var str_desc = "Mon's attacks do more damage"
var int_desc = "Mon is more likely to listen to you and make good decisions"
var type_desc = "Change mon's element to WATER, FIRE or EARTH"
var gamble_desc = "Who knows?! Hint: The more losses you have, the luckier you are!"


signal upgrades_finished

func _ready():
	get_mon()
	get_player()


func _process(_delta):
	if upgrade_time:
		current_focus = get_viewport().gui_get_focus_owner()
		update_button_description()
		hp_stat.text = "HP: " + str(mon.max_health)
		str_stat.text = "STR: " + str(mon.strength)
		int_stat.text = "INT: " + str(mon.intelligence)
		type_stat.text = mon.elm_type
		mon.hp_bar.value = mon.max_health
		mon.health_label.text = str(mon.max_health)
		mon.max_health_label.text = str(mon.max_health)
		player_wins.text = str(player.wins)
		player_losses.text = str(player.losses)


func get_mon():
	mon = get_child(1).get_child(0)


func get_player():
	player = mon.get_parent()


func switch_upgrade_time(fight_time):
	if fight_time:
		upgrade_time = false
	else:
		upgrade_time = true
		points_to_spend = 3
		upgrade_buttons[0].grab_focus()
		for button in upgrade_buttons:
			button.disabled = false


func _on_button_pressed(button_name):
	match button_name:
		"hp":
			points_to_spend -= 1
			mon.max_health += 1
		"str":
			points_to_spend -= 1
			mon.strength += 1
		"int":
			points_to_spend -= 1
			mon.intelligence += 1
		"gamble":
			points_to_spend -= 1
			gamble()
		"type":
			points_to_spend -= 1
			var rand_num = randi_range(1,3)
			if rand_num == 1:
				mon.elm_type = "FIRE"
			if rand_num == 2:
				mon.elm_type = "WATER"
			if rand_num == 3:
				mon.elm_type = "EARTH"
	if points_to_spend == 0:
		for button in upgrade_buttons:
			button.disabled = true
		emit_signal("upgrades_finished")


func gamble():
	var player_losses = player.losses
	var random_num = randi_range(0, 8)
	random_num += player_losses
	match random_num:
		0:
			if mon.cursed == false:
				mon.cursed = true
			else:
				mon.cursed = false
			print("cursed or un-cursed")
		1:
			print("made mon slower")
			mon.speed -= 25
		2:
			print("made mon smaller")
			mon.scale -= Vector2(.15, .15)
		3:
			print("made mon bigger")
			mon.scale += Vector2(.15, .15)
		4:
			print("made mon faster")
			mon.speed += 25
		5:
			print("gave mon ADHD")
			if mon.max_think_time == 1.5:
				print("mon already has ADHD, adding random stat point instead")
				increase_random_stats(1,1)
			mon.max_think_time = 1.5
		6:
			print("1 stat 1 point higher")
			increase_random_stats(1,1)
		7:
			print("2 stats 1 point higher")
			increase_random_stats(2,1)
		8:
			print("1 stat 2 points higher")
			increase_random_stats(1,2)
		9:
			print("3 stats 1 point higher")
			increase_random_stats(3,1)
		_:
			print("1 stat 3 points higher")
			increase_random_stats(1,3)


func increase_random_stats(stats:int, alter_by:int):
	var possible_stats = [1, 2, 3]
	var random_stat = possible_stats.pick_random()
	possible_stats.remove_at(possible_stats.find(random_stat))
	var random_stat2 = possible_stats.pick_random()
	possible_stats.remove_at(possible_stats.find(random_stat2))
	var random_stat3 = possible_stats.pick_random()
	if stats == 1:
		if random_stat == 1:
			mon.max_health += alter_by
		if random_stat == 2:
			mon.strength += alter_by
		else:
			mon.intelligence += alter_by
	if stats == 2:
		if random_stat == 1:
			mon.max_health += alter_by
		if random_stat == 2:
			mon.strength += alter_by
		if random_stat == 3:
			mon.intelligence += alter_by
		if random_stat2 == 1:
			mon.max_health += alter_by
		if random_stat2 == 2:
			mon.strength += alter_by
		if random_stat2 == 3:
			mon.intelligence += alter_by
	if stats == 3:
		if random_stat == 1:
			mon.max_health += alter_by
		if random_stat == 2:
			mon.strength += alter_by
		if random_stat == 3:
			mon.intelligence += alter_by
		if random_stat2 == 1:
			mon.max_health += alter_by
		if random_stat2 == 2:
			mon.strength += alter_by
		if random_stat2 == 3:
			mon.intelligence += alter_by
		if random_stat3 == 1:
			mon.max_health += alter_by
		if random_stat3 == 2:
			mon.strength += alter_by
		if random_stat3 == 3:
			mon.intelligence += alter_by


func update_button_description():
	match current_focus.name:
		"hp":
			description.text = hp_desc
		"str":
			description.text = str_desc
		"int":
			description.text = int_desc
		"type":
			description.text = type_desc
		"gamble":
			description.text = gamble_desc
