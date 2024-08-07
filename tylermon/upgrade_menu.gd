extends Control
var mon
var player
var upgrade_time : bool = false
var points_to_spend : int = 0
var players_done_upgrading : int = 0
var current_focus

@onready var cursor = $cursor
var moved_stick: bool = false

@onready var hp_stat = $margin/hbox/buttons/hbox/stat1
@onready var str_stat = $margin/hbox/buttons/hbox2/stat2
@onready var int_stat = $margin/hbox/buttons/hbox3/stat3
@onready var type_stat = $margin/hbox/buttons/hbox5/stat4
@onready var description = $margin/hbox/buttons/description
@onready var place = $margin/hbox/buttons/HBoxContainer/place_num
@onready var vp = $margin/hbox/buttons/HBoxContainer/vp

@onready var hp_button = $margin/hbox/buttons/hbox/hp
@onready var str_button = $margin/hbox/buttons/hbox2/str
@onready var int_button = $margin/hbox/buttons/hbox3/int
@onready var gamble_button = $margin/hbox/buttons/hbox7/gamble
@onready var type_button = $margin/hbox/buttons/hbox5/type
@onready var upgrade_buttons = [hp_button, str_button, int_button, gamble_button, type_button]


var hp_desc = "+1 Tylermon max health 🧀"
var str_desc = "Tylermon's attacks do more damage"
var int_desc = "Tylermon is more likely to make good decisions"
var type_desc = "Change Tylermon's element to WATER, FIRE or GRASS"
var gamble_desc = "Feeling down? The more you are losing the luckier you are!"

var upgrade_options: Array = ["hp", "str", "int", "type", "gamble"]
var upgrade_position: int = 0

signal upgrades_finished
signal upgraded(type)
signal set_element

func _ready():
	get_mon()
	get_player()


func _process(_delta):
	if points_to_spend > 0:
		cursor.visible = true
		var vertical_input: float = round(Controller.GetLeftStick(player.controller_port).y)
		if !vertical_input:
			moved_stick = false
		if !moved_stick:
			if vertical_input > 0:
				upgrade_position += 1
				cursor.position.y += 35
				moved_stick = true
			elif vertical_input < 0:
				upgrade_position -= 1
				cursor.position.y -= 35
				moved_stick = true
		if upgrade_position >= upgrade_options.size():
			upgrade_position = 0
			cursor.position.y = 42
		elif upgrade_position < 0:
			upgrade_position = upgrade_options.size() - 1
			cursor.position.y = 182
		if moved_stick:
			_on_mouse_entered(upgrade_options[upgrade_position])
		if Controller.IsControllerButtonJustPressed(player.controller_port, JOY_BUTTON_A):
			_on_button_pressed(upgrade_options[upgrade_position])
	else:
		cursor.visible = false
	
	if upgrade_time:
		set_place()
		hp_stat.text = "HP: " + str(mon.max_health)
		str_stat.text = "STR: " + str(mon.strength)
		int_stat.text = "INT: " + str(mon.intelligence)
		type_stat.text = mon.elm_type
		mon.hp_bar.value = mon.max_health
		mon.health_label.text = str(mon.max_health)
		mon.max_health_label.text = str(mon.max_health)
		vp.text = str(player.wins)


func get_mon():
	mon = get_child(2).get_child(0)


func get_player():
	player = mon.get_parent()


func switch_upgrade_time(fight_time):
	if fight_time:
		upgrade_time = false
	else:
		upgrade_time = true
		points_to_spend = 3
		for button in upgrade_buttons:
			button.disabled = false


func _on_button_pressed(button_name):
	match button_name:
		"hp":
			points_to_spend -= 1
			mon.max_health += 1
			emit_signal("upgraded", "good")
		"str":
			points_to_spend -= 1
			mon.strength += 1
			emit_signal("upgraded", "good")
			if mon.strength >= 10 && mon.buff == false:
				mon.buff = true
				mon.hair.visible = true
		"int":
			points_to_spend -= 1
			mon.intelligence += 1
			emit_signal("upgraded", "good")
			if mon.intelligence >= 10 && mon.smart == false:
				mon.smart = true
				mon.glasses.visible = true
				
		"gamble":
			points_to_spend -= 1
			gamble()
		"type":
			points_to_spend -= 1
			var rand_num = randi_range(1,3)
			if rand_num == 1:
				if mon.elm_type != "FIRE":
					emit_signal("set_element", "FIRE")
				else: 
					emit_signal("set_element", "WATER")
			if rand_num == 2:
				if mon.elm_type != "WATER":
					emit_signal("set_element", "WATER")
				else:
					emit_signal("set_element", "GRASS")
			if rand_num == 3:
				if mon.elm_type != "GRASS":
					emit_signal("set_element", "GRASS")
				else:
					emit_signal("set_element", "FIRE")
			emit_signal("upgraded", "good")
	if points_to_spend == 0:
		for button in upgrade_buttons:
			button.disabled = true
		emit_signal("upgrades_finished")	


func gamble():
	var random_num = randi_range(0, 7)
	if player.current_place == 1:
		if random_num == 0:
			pass
		else:
			random_num -= 1
	elif player.current_place == 2:
		random_num
	else:
		random_num += player.current_place

	match random_num:
		0:
			if mon.cursed == false:
				mon.cursed = true
				mon.hat.visible = true
				description.text = "Mon is CURSED"
				emit_signal("upgraded", "bad")
			else:
				mon.cursed = false
				description.text = "Mon has been un-cursed"
				mon.hat.visible = false
				emit_signal("upgraded", "bad")
		1:
			mon.speed -= 25
			description.text = "Mon is sluggish!"
			emit_signal("upgraded", "bad")
		2:
			mon.get_node("scalable_nodes").scale -= Vector2(.15, .15)
			description.text = "Mon has shrunk!"
			emit_signal("upgraded", "bad")
		3:
			mon.get_node("scalable_nodes").scale += Vector2(.15, .15)
			description.text = "Mon has grown!"
			emit_signal("upgraded", "bad")
		4:
			mon.speed += 25
			description.text = "Mon is speedier!"
			emit_signal("upgraded", "bad")
		5:
			if mon.max_think_time <= 1.5:
				increase_random_stats(1,1)
				emit_signal("upgraded", "good")
			else:
				mon.max_think_time -= 1
				description.text = "Mon will change it's mind quicker"
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
	if mon.strength >= 10 && mon.buff == false:
		mon.buff = true
		mon.hair.visible = true
	if mon.intelligence >= 10 && mon.smart == false:
		mon.smart = true
		mon.glasses.visible = true

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
		player_totals.append(player.wins)
	player_totals.sort()
	var remove_duplicates = array_unique(player_totals)
	remove_duplicates.reverse()
	var index = remove_duplicates.find(player.wins)
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
		place.set("theme_override_colors/font_color", Color('ffffff'))
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
