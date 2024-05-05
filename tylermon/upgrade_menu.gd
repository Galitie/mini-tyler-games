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
@onready var description = $margin/hbox/buttons/description
@onready var place = $margin/hbox/buttons/HBoxContainer/place_num

@onready var hp_button = $margin/hbox/buttons/hbox/hp
@onready var str_button = $margin/hbox/buttons/hbox2/str
@onready var int_button = $margin/hbox/buttons/hbox3/int
@onready var gamble_button = $margin/hbox/buttons/hbox7/gamble
@onready var type_button = $margin/hbox/buttons/hbox5/type
@onready var upgrade_buttons = [hp_button, str_button, int_button, gamble_button, type_button]


var hp_desc = "+2 max mon health"
var str_desc = "Mon's attacks do more damage"
var int_desc = "Mon is more likely to listen to you and make good decisions"
var type_desc = "Change mon's element to WATER, FIRE or EARTH"
var gamble_desc = "Who knows?! Hint: The more you are losing the luckier you are!"


signal upgrades_finished
signal upgraded(type)

func _ready():
	get_mon()
	get_player()


func _process(_delta):
	if upgrade_time:
		set_place()
		hp_stat.text = "HP: " + str(mon.max_health)
		str_stat.text = "STR: " + str(mon.strength)
		int_stat.text = "INT: " + str(mon.intelligence)
		type_stat.text = mon.elm_type
		mon.hp_bar.value = mon.max_health
		mon.health_label.text = str(mon.max_health)
		mon.max_health_label.text = str(mon.max_health)

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
			mon.max_health += 2
			emit_signal("upgraded", "good")
		"str":
			points_to_spend -= 1
			mon.strength += 1
			emit_signal("upgraded", "good")
		"int":
			points_to_spend -= 1
			mon.intelligence += 1
			emit_signal("upgraded", "good")
		"gamble":
			points_to_spend -= 1
			gamble()
		"type":
			points_to_spend -= 1
			var rand_num = randi_range(1,3)
			if rand_num == 1:
				if mon.elm_type != "FIRE":
					mon.elm_type = "FIRE"
				else: 
					mon.elm_type = "WATER"
			if rand_num == 2:
				if mon.elm_type != "WATER":
					mon.elm_type = "WATER"
				else:
					mon.elm_type = "EARTH"
			if rand_num == 3:
				if mon.elm_type != "EARTH":
					mon.elm_type = "EARTH"
				else:
					mon.elm_type = "FIRE"
			emit_signal("upgraded", "good")
	if points_to_spend == 0:
		for button in upgrade_buttons:
			button.disabled = true
		emit_signal("upgrades_finished")	


func gamble():
	var random_num = randi_range(0, 7)
	random_num += player.current_place
	if random_num < 0:
		random_num = 0
	match random_num:
		0:
			if mon.cursed == false:
				mon.cursed = true
				description.text = "Mon is CURSED"
				emit_signal("upgraded", "bad")
			else:
				mon.cursed = false
				description.text = "Mon has been un-cursed"
				emit_signal("upgraded", "bad")
		1:
			mon.speed -= 25
			description.text = "Mon is sluggish!"
			emit_signal("upgraded", "bad")
		2:
			mon.get_node("scalable_nodes").scale -= Vector2(.15, .15)
			description.text = "Mon has shrunk!"
			emit_signal("upgraded", "good")
		3:
			mon.get_node("scalable_nodes").scale += Vector2(.15, .15)
			description.text = "Mon has grown!"
			emit_signal("upgraded", "good")
		4:
			mon.speed += 25
			description.text = "Mon is speedier!"
			emit_signal("upgraded", "good")
		5:
			if mon.max_think_time == 1.5:
				increase_random_stats(1,1)
				emit_signal("upgraded", "good")
			else:
				mon.max_think_time = 1.5
				description.text = "Mon has ADHD and will change it's mind quicker"
				emit_signal("upgraded", "good")
		6:
			increase_random_stats(1,1)
			emit_signal("upgraded", "good")
		7:
			increase_random_stats(2,1)
			emit_signal("upgraded", "good")
		8:
			increase_random_stats(1,2)
			emit_signal("upgraded", "good")
		9:
			increase_random_stats(3,1)
			emit_signal("upgraded", "good")
		_:
			increase_random_stats(1,3)
			emit_signal("upgraded", "good")


func increase_random_stats(stats:int, alter_by:int):
	var possible_stats = [1, 2, 3]
	var random_stat = possible_stats.pick_random()
	possible_stats.remove_at(possible_stats.find(random_stat))
	var random_stat2 = possible_stats.pick_random()
	possible_stats.remove_at(possible_stats.find(random_stat2))
	var random_stat3 = possible_stats.pick_random()
	if stats == 1:
		if random_stat == 1:
			mon.max_health += (alter_by + 1)
			update_description(alter_by, "health", null, null)
		if random_stat == 2:
			mon.strength += alter_by
			update_description(alter_by, "strength", null, null)
		if random_stat == 3:
			mon.intelligence += alter_by
			update_description(alter_by, "intelligence", null, null)
	elif stats == 2:
		var stat
		var stat2
		if random_stat == 1:
			mon.max_health += (alter_by + 1)
			stat = "health"
		if random_stat == 2:
			mon.strength += alter_by
			stat = "strength"
		if random_stat == 3:
			mon.intelligence += alter_by
			stat = "intelligence"
		if random_stat2 == 1:
			mon.max_health += (alter_by + 1)
			stat2 = "health"
		if random_stat2 == 2:
			mon.strength += alter_by
			stat2 = "strength"
		if random_stat2 == 3:
			mon.intelligence += alter_by
			stat2 = "intelligence"
		update_description(alter_by, stat, stat2, null)
	elif stats == 3:
		var stat
		var stat2
		var stat3
		if random_stat == 1:
			mon.max_health += alter_by + 1
			stat = "health"
		if random_stat == 2:
			mon.strength += alter_by
			stat = "strength"
		if random_stat == 3:
			mon.intelligence += alter_by
			stat = "intelligence"
		if random_stat2 == 1:
			mon.max_health += alter_by + 1
			stat2 = "health"
		if random_stat2 == 2:
			mon.strength += alter_by
			stat2 = "strength"
		if random_stat2 == 3:
			mon.intelligence += alter_by
			stat2 = "intelligence"
		if random_stat3 == 1:
			mon.max_health += alter_by + 1
			stat3 = "health"
		if random_stat3 == 2:
			mon.strength += alter_by
			stat3 = "strength"
		if random_stat3 == 3:
			mon.intelligence += alter_by
			stat3 = "intelligence"
		update_description(alter_by, stat, stat2, stat3)


func _on_mouse_entered(button_name):
	match button_name:
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


func set_place():
	var players = get_tree().get_nodes_in_group("player")
	var player_totals = []
	for player in players:
		player.total = player.wins
		player_totals.append(player.total)
	player_totals.sort()
	var remove_duplicates = array_unique(player_totals)
	remove_duplicates.reverse()
	var index = remove_duplicates.find(player.total)
	var index_corrected = index + 1
	var add
	player.current_place = index_corrected
	index_corrected = str(index_corrected)
	if index_corrected == '1':
		add = "st"
		place.set("theme_override_colors/font_color", Color('00cb00'))
	if index_corrected == '2':
		add = "nd"
		place.set("theme_override_colors/font_color", Color('ffffff'))
	if index_corrected == '3':
		add = "rd"
		place.set("theme_override_colors/font_color", Color('e90000'))
	if index_corrected == '4':
		add = "th"
		place.set("theme_override_colors/font_color", Color('e90000'))
	place.text = index_corrected + add + " place"


func array_unique(array: Array) -> Array:
	var unique: Array = []
	for item in array:
		if not unique.has(item):
			unique.append(item)
	return unique


func update_description(amount : int, stat, stat2, stat3):
	var plural = ""
	if amount > 1:
		plural = "s"
	if stat2 == null and stat3 == null:
		description.text = "Mon gained " + str(amount) + " " + str(stat) + " point" + plural + "!"
	elif stat != null and stat2 != null and stat3 == null:
		description.text = "Mon gained " + str(amount) + " " + str(stat) + " and " +  str(amount) + " " + str(stat2) + " point" + plural + "!"
	else:
		description.text = "Mon gained " + str(amount) + " " + str(stat) + ", " +  str(amount) + " " + str(stat2) + " and " +  str(amount) + " " + str(stat3) + " point" + plural + "!"
