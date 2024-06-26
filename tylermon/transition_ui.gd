extends MarginContainer

@onready var title_label = $center_container/vbox/vbox/title_text
@onready var large_confetti = $confetti
@onready var sm_left_confetti = $confetti2
@onready var sm_right_confetti = $confetti3


var end_of_game = false


func _ready():
	get_tree().get_root().get_node("tylermon").connect("winners", update_winners)
	get_tree().get_root().get_node("tylermon").connect("clear_winners", clear_winners)
	get_tree().get_root().get_node("tylermon").connect("final_winners", show_final_winners)
	title_label.text = ""

func _process(_delta):
	pass


func update_winners(winners):
	if winners.size() == 0:
		title_label.text = "NO WINNERS THIS ROUND"
	if winners.size() == 1:
		title_label.text = "🎉 ROUND WINNER 🎉"
	else:
		title_label.text = "🎉 ROUND WINNERS 🎉"
	build_nodes(winners)
	sm_left_confetti.emitting = true
	sm_right_confetti.emitting = true


func clear_winners():
	title_label.text = ""
	var container = get_node("center_container/vbox/winners")
	var children = container.get_children()
	if children.size() > 0:
		for child in children:
			child.queue_free()
	var loser_container = get_node("center_container/vbox/losers")
	var loser_children = loser_container.get_children()
	if loser_children.size() > 0:
		for child in loser_children:
			child.queue_free()
	sm_left_confetti.emitting = false
	sm_right_confetti.emitting = false
	large_confetti.emitting = false


func show_final_winners(winners):
	end_of_game = true
	large_confetti.emitting = true
	sm_left_confetti.emitting = true
	sm_right_confetti.emitting = true
	if winners.size() == 1:
		title_label.text = "✨🏆 GAME WINNER 🏆✨"
	else:
		title_label.text = "✨🏆 GAME WINNERS 🏆✨"
	build_nodes(winners)


func build_nodes(winners):
	var container = get_node("center_container/vbox/winners")
	for winner in winners:
		var image = TextureRect.new()
		var label = Label.new()
		label.theme = load("res://tylermon/tylermon_theme.tres")
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.set("theme_override_colors/font_color", Color("000000"))
		label.text = "Total VP: " + str(winner.wins)
		var sprite_frame = winner.get_child(0).get_node("scalable_nodes").get_child(0).get_sprite_frames()
		image.texture = sprite_frame.get_frame_texture("idle",0)
		image.modulate = winner.get_child(0).custom_color
		var vbox = VBoxContainer.new()
		vbox.add_child(label)
		vbox.add_child(image)
		vbox.set("theme_override_constants/separation", -60)
		container.add_child(vbox)
	build_losers_nodes(winners)


func build_losers_nodes(winners):
	var players = get_tree().get_nodes_in_group("player")
	var losers = []
	
	for player in players:
		if !winners.has(player):
			losers.append(player)
	
	var container = get_node("center_container/vbox/losers")
	for loser in losers:
		var image = TextureRect.new()
		var label = Label.new()
		var sprite_frame = loser.get_child(0).get_node("scalable_nodes").get_child(0).get_sprite_frames()
		var texture = sprite_frame.get_frame_texture("idle",0)
		image.texture = texture
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.custom_minimum_size = Vector2(100,100)
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.set("theme_override_colors/font_color", Color("000000"))
		label.text = "Total VP: " + str(loser.wins)
		label.theme = load("res://tylermon/tylermon_theme.tres")
		image.modulate = loser.get_child(0).custom_color
		var vbox = VBoxContainer.new()
		vbox.add_child(label)
		vbox.add_child(image)
		vbox.set("theme_override_constants/separation", -20)
		container.add_child(vbox)	

