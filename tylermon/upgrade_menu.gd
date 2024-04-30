extends Control
var mon
var upgrade_time : bool = false
var points_to_spend : int = 3

@onready var hp_stat = $margin/hbox/buttons/hbox/stat1
@onready var str_stat = $margin/hbox/buttons/hbox2/stat2
@onready var int_stat = $margin/hbox/buttons/hbox3/stat3
@onready var type_stat = $margin/hbox/buttons/hbox5/stat4

@onready var hp_button = $margin/hbox/buttons/hbox/hp
@onready var str_button = $margin/hbox/buttons/hbox2/str
@onready var int_button = $margin/hbox/buttons/hbox3/int
@onready var gamble_button = $margin/hbox/buttons/button6
@onready var type_button = $margin/hbox/buttons/hbox5/type

@onready var upgrade_buttons = [hp_button, str_button, int_button, gamble_button, type_button]

func _ready():
	get_mon()


func _process(_delta):
	if upgrade_time:
		hp_stat.text = "HP: " + str(mon.max_health)
		str_stat.text = "STR: " + str(mon.strength)
		int_stat.text = "INT: " + str(mon.intelligence)
		type_stat.text = mon.elm_type
		mon.hp_bar.value = mon.max_health
		mon.health_label.text = str(mon.max_health)
		mon.max_health_label.text = str(mon.max_health)


func get_mon():
	mon = get_child(1).get_child(0)


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
			mon.intelligence += randi_range(-1,2)
			mon.strength += randi_range(-1,2)
			mon.max_health += randi_range(-1,2)
			if mon.strength <= 0:
				mon.strength = 1
			if mon.max_health < 1:
				mon.max_health = 1	
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
