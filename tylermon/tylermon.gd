extends Node2D

var round = 0
enum player {PL1, PL2, PL3, PL4}
var fight_time = false


func _ready():
	pass 


func _process(delta):
	pass


func _on_round_timer_timeout():
	if fight_time:
		fight_time = false
	else:
		fight_time = true
