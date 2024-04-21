extends Control
var mon
var upgrade_time : bool = false
@onready var hp_stat = $margin/hbox/stats/stat_bar/stat1
@onready var str_stat = $margin/hbox/stats/stat_bar/stat2
@onready var int_stat = $margin/hbox/stats/stat_bar/stat3
@onready var type_stat = $margin/hbox/stats/stat_bar/stat4



func _ready():
	get_mon()


func _process(delta):
	if upgrade_time:
		hp_stat.text = "HP: " + str(mon.max_health)
		str_stat.text = "STR: " + str(mon.strength)
		int_stat.text = "INT: " + str(mon.intelligence)
		type_stat.text = str(mon.elm_type)


func get_mon():
	mon = get_child(1).get_child(0)


func switch_upgrade_time(fight_time):
	if fight_time:
		upgrade_time = false
	else:
		upgrade_time = true
