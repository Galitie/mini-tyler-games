extends Control
var mon
var player
var upgrade_time : bool = false
var points_to_spend : int = 0
var players_done_upgrading : int = 0
var current_focus
var scale_amount : float = .02
var place_set: bool = false

@onready var cursor = $cursor
var moved_stick: bool = false

@onready var hp_stat = $margin/hbox/buttons/hbox/stat1
@onready var str_stat = $margin/hbox/buttons/hbox2/stat2
@onready var int_stat = $margin/hbox/buttons/hbox3/stat3
@onready var description = $margin/hbox/buttons/description

@onready var hp_button = $margin/hbox/buttons/hbox/hp
@onready var str_button = $margin/hbox/buttons/hbox2/str
@onready var int_button = $margin/hbox/buttons/hbox3/int
@onready var gamble_button = $margin/hbox/buttons/hbox7/gamble
@onready var upgrade_buttons = [gamble_button, hp_button, str_button, int_button]


var hp_desc = "+1 max health"
var str_desc = "Attacks do more damage"
var int_desc = "Attack and block more often"
var gamble_desc = "Gambling is fun!!!"

var upgrade_options: Array = ["gamble","hp", "str", "int"]
var upgrade_position: int = 0

signal upgraded
signal upgrades_finished
signal first_place

func _ready():
	get_mon()
	get_player()


func _physics_process(_delta):
	if points_to_spend > 0:
		cursor.visible = true
		var vertical_input: float = round(Controller.GetLeftStick(player.controller_port).y)
		if !vertical_input:
			moved_stick = false
		if !moved_stick:
			if vertical_input > 0:
				upgrade_position += 1
				cursor.position.y += 38
				moved_stick = true
			elif vertical_input < 0:
				upgrade_position -= 1
				cursor.position.y -= 38
				moved_stick = true
		if upgrade_position >= upgrade_options.size():
			upgrade_position = 0
			cursor.position.y = 58
		elif upgrade_position < 0:
			upgrade_position = upgrade_options.size() - 1
			cursor.position.y = 173
		if moved_stick:
			_on_mouse_entered(upgrade_options[upgrade_position])
		if Controller.IsControllerButtonJustPressed(player.controller_port, JOY_BUTTON_A):
			_on_button_pressed(upgrade_options[upgrade_position])
	else:
		cursor.visible = false
	
	if upgrade_time:
		hp_stat.text = "HP: " + str(mon.max_health)
		str_stat.text = "STR: " + str(mon.strength)
		int_stat.text = "INT: " + str(mon.intelligence)
		if points_to_spend == 3:
			%points.text = "Cookies left: 🍪🍪🍪"
		if points_to_spend == 2:
			%points.text = "Cookies left: 🍪🍪"
		if points_to_spend == 1:
			%points.text = "Cookies left: 🍪"
		if points_to_spend == 0:
			%points.text = "All 🍪s eaten - please wait!"
		mon.hp_bar.value = mon.max_health
		mon.health_label.text = str(mon.max_health)
		mon.max_health_label.text = str(mon.max_health)
	
	if upgrade_time && !place_set:
		set_place()
		place_set = true

func get_mon():
	mon = get_child(3).get_child(0)


func get_player():
	player = mon.get_parent()


func switch_upgrade_time(fight_time):
	if fight_time:
		upgrade_time = false
		place_set = false
	else:
		description.text = "Gambling is fun!!!"
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
			mon.get_node("%scalable_nodes").scale += Vector2(scale_amount, scale_amount)
			mon.get_node("collision").scale += Vector2(scale_amount, scale_amount)
			mon.get_node("%trail").process_material.set("scale_min", mon.get_node("%trail").process_material.get("scale_min") + scale_amount)
			if mon.max_health >= 15 && mon.tank == false:
				mon.tank = true
				mon.get_node("%scalable_nodes").scale += Vector2(.25, .25)
				mon.get_node("collision").scale += Vector2(.25, .25)
				mon.get_node("%trail").process_material.set("scale_min", mon.get_node("%trail").process_material.get("scale_min") + .25)
				description.text = "BIG BOIIIIIIIIIII"
		"str":
			points_to_spend -= 1
			mon.strength += 1
			emit_signal("upgraded", "good")
			if mon.strength >= 10 && mon.buff == false:
				mon.buff = true
				if mon.cursed == false:
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

	if points_to_spend == 0:
		$anim_player.stop()
		description.text = ""
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
	if player.current_place == 2:
		pass
	else:
		random_num += player.current_place

	match random_num:
		0 or 1:
			if mon.cursed == false:
				mon.cursed = true
				mon.hat.visible = true
				mon.hair.visible = false
				description.text = "Mon is CURSED"
				emit_signal("upgraded", "bad")
			else:
				mon.cursed = false
				description.text = "Mon has been un-cursed"
				mon.hat.visible = false
				if mon.buff == true:
					mon.hair.visible = true
				emit_signal("upgraded", "bad")
		2:
			mon.speed -= 25
			description.text = "Mon is sluggish!"
			emit_signal("upgraded", "bad")
		3:
			mon.get_node("%scalable_nodes").scale -= Vector2(.15, .15)
			mon.get_node("collision").scale -= Vector2(.15, .15)
			mon.get_node("%trail").process_material.set("scale_max", mon.get_node("%trail").process_material.get("scale_max") - .15)
			description.text = "Mon has shrunk!"
			emit_signal("upgraded", "bad")
		4:
			mon.speed += 25
			description.text = "Mon moves faster!"
			emit_signal("upgraded", "bad")
		5:
			increase_random_stats(1,1)
			emit_signal("upgraded", "good")
		6:
			if mon.max_think_time <= 1.5:
				increase_random_stats(1,1)
				emit_signal("upgraded", "good")
			else:
				mon.max_think_time -= .5
				description.text = "Mon is more ADHD"
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
		if mon.cursed == false:
			mon.hair.visible = true
		description.text = "KAAMAAAYAAMAAAHAAAAA"
	if mon.intelligence >= 10 && mon.smart == false:
		mon.smart = true
		mon.glasses.visible = true
		description.text = "Pretty smart for a dummy"
	if mon.max_health >= 15 && mon.tank == false:
		mon.tank = true
		mon.get_node("%scalable_nodes").scale += Vector2(.25, .25)
		mon.get_node("collision").scale += Vector2(.25, .25)
		mon.get_node("%trail").process_material.set("scale_min", mon.get_node("%trail").process_material.get("scale_min") + .25)
		description.text = "BIG BOIIIIIIIIIII"


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
			mon.get_node("%scalable_nodes").scale += Vector2(scale_amount, scale_amount)
			mon.get_node("collision").scale += Vector2(scale_amount, scale_amount)
			mon.get_node("%trail").process_material.set("scale_min", mon.get_node("%trail").process_material.get("scale_min") + scale_amount)
			update_description(alter_by, "hp", null, null)
		if random_stat == 2:
			mon.strength += alter_by
			update_description(alter_by, "str", null, null)
		if random_stat == 3:
			mon.intelligence += alter_by
			update_description(alter_by, "int", null, null)
	elif stats == 2:
		var stat
		var stat2
		if random_stat == 1:
			mon.max_health += (alter_by + 1)
			mon.get_node("%scalable_nodes").scale += Vector2(scale_amount, scale_amount)
			mon.get_node("collision").scale += Vector2(scale_amount, scale_amount)
			mon.get_node("%trail").process_material.set("scale_min", mon.get_node("%trail").process_material.get("scale_min") + scale_amount)
			stat = "hp"
		if random_stat == 2:
			mon.strength += alter_by
			stat = "str"
		if random_stat == 3:
			mon.intelligence += alter_by
			stat = "int"
		if random_stat2 == 1:
			mon.max_health += (alter_by + 1)
			mon.get_node("%scalable_nodes").scale += Vector2(scale_amount, scale_amount)
			mon.get_node("collision").scale += Vector2(scale_amount, scale_amount)
			mon.get_node("%trail").process_material.set("scale_min", mon.get_node("%trail").process_material.get("scale_min") + scale_amount)
			stat2 = "hp"
		if random_stat2 == 2:
			mon.strength += alter_by
			stat2 = "str"
		if random_stat2 == 3:
			mon.intelligence += alter_by
			stat2 = "int"
		update_description(alter_by, stat, stat2, null)
	elif stats == 3:
		var stat
		var stat2
		var stat3
		if random_stat == 1:
			mon.max_health += alter_by + 1
			mon.get_node("%scalable_nodes").scale += Vector2(scale_amount, scale_amount)
			mon.get_node("collision").scale += Vector2(scale_amount, scale_amount)
			mon.get_node("%trail").process_material.set("scale_min", mon.get_node("%trail").process_material.get("scale_min") + scale_amount)
			stat = "hp"
		if random_stat == 2:
			mon.strength += alter_by
			stat = "str"
		if random_stat == 3:
			mon.intelligence += alter_by
			stat = "int"
		if random_stat2 == 1:
			mon.max_health += alter_by + 1
			mon.get_node("%scalable_nodes").scale += Vector2(scale_amount, scale_amount)
			mon.get_node("collision").scale += Vector2(scale_amount, scale_amount)
			mon.get_node("%trail").process_material.set("scale_min", mon.get_node("%trail").process_material.get("scale_min") + scale_amount)
			stat2 = "hp"
		if random_stat2 == 2:
			mon.strength += alter_by
			stat2 = "str"
		if random_stat2 == 3:
			mon.intelligence += alter_by
			stat2 = "int"
		if random_stat3 == 1:
			mon.max_health += alter_by + 1
			mon.get_node("%scalable_nodes").scale += Vector2(scale_amount, scale_amount)
			mon.get_node("collision").scale += Vector2(scale_amount, scale_amount)
			mon.get_node("%trail").process_material.set("scale_min", mon.get_node("%trail").process_material.get("scale_min") + scale_amount)
			stat3 = "hp"
		if random_stat3 == 2:
			mon.strength += alter_by
			stat3 = "str"
		if random_stat3 == 3:
			mon.intelligence += alter_by
			stat3 = "int"
		update_description(alter_by, stat, stat2, stat3)


func _on_mouse_entered(button_name):
	match button_name:
		"hp":
			description.text = hp_desc
		"str":
			description.text = str_desc
		"int":
			description.text = int_desc
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
	player.current_place = index_corrected
	index_corrected = str(index_corrected)
	if index_corrected == '1':
		%gamble.text = "🎲 Gramble"
		first_place.emit(true)
	if index_corrected == '2':
		%gamble.text = "🎲 Gramble"
		first_place.emit(false)
	if index_corrected == '3':
		$anim_player.play("pulse")
		%gamble.text = "🎲 Mon is extra lucky!"
		first_place.emit(false)
	if index_corrected == '4':
		$anim_player.play("pulse")
		%gamble.text = "🎲 Mon is extra lucky!"
		first_place.emit(false)


func array_unique(array: Array) -> Array:
	var unique: Array = []
	for item in array:
		if not unique.has(item):
			unique.append(item)
	return unique


func update_description(amount : int, stat, stat2, stat3):
	if stat2 == null and stat3 == null:
		description.text = "Gained " + str(amount) + " " + str(stat) + "!"
	elif stat != null and stat2 != null and stat3 == null:
		description.text = "Gained " + str(amount) + " " + str(stat) + " and " +  str(amount) + " " + str(stat2) + "!"
	else:
		description.text = "Gained " + str(amount) + " " + str(stat) + ", " +  str(amount) + " " + str(stat2) + " and " +  str(amount) + " " + str(stat3) + "!"
