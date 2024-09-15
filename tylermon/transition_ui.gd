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
		var images = TextureRect.new()
		var label = Label.new()
		var label_name = Label.new()
		var image_mon = TextureRect.new()
		var image_hat = TextureRect.new()
		var image_glasses = TextureRect.new()
		var image_hair = TextureRect.new()
		label.theme = load("res://tylermon/tylermon_theme.tres")
		label_name.theme = load("res://tylermon/tylermon_theme.tres")
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.set("theme_override_colors/font_color", Color("000000"))
		label_name.set("theme_override_colors/font_color", Color("000000"))
		label.text = "Total 👑 " + str(winner.wins)
		label_name.text = winner.get_child(0).mon_name
		var sprite_frame = winner.get_child(0).get_node("scalable_nodes").get_child(0).get_sprite_frames()
		images.texture = sprite_frame.get_frame_texture("idle",0)
		image_mon.texture = sprite_frame.get_frame_texture("idle",0)
		image_mon.modulate = winner.get_child(0).custom_color
		images.add_child(image_mon)
		var vbox = VBoxContainer.new()
		if winner.get_child(0).buff == true:
			var sprite_hair = winner.get_child(0).get_node("scalable_nodes").get_child(2).get_sprite_frames()
			image_hair.texture = sprite_hair.get_frame_texture("idle",0)
			images.add_child(image_hair)
		if winner.get_child(0).cursed == true:
			var sprite_frame_hat = winner.get_child(0).get_node("scalable_nodes").get_child(3).get_sprite_frames()
			image_hat.texture = sprite_frame_hat.get_frame_texture("idle",0)
			images.add_child(image_hat)
		if winner.get_child(0).smart == true:
			var sprite_frame_glasses = winner.get_child(0).get_node("scalable_nodes").get_child(1).get_sprite_frames()
			image_glasses.texture = sprite_frame_glasses.get_frame_texture("idle",0)
			images.add_child(image_glasses)
		vbox.add_child(images)
		vbox.add_child(label_name)
		vbox.add_child(label)
		vbox.set("theme_override_constants/separation", 5)
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
		var images = TextureRect.new()
		var label = Label.new()
		var label_name = Label.new()
		var image_mon = TextureRect.new()
		var image_hat = TextureRect.new()
		var image_glasses = TextureRect.new()
		var image_hair = TextureRect.new()
		var sprite_frame = loser.get_child(0).get_node("scalable_nodes").get_child(0).get_sprite_frames()
		var texture = sprite_frame.get_frame_texture("idle",0)
		images.texture = texture
		images.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		images.custom_minimum_size = Vector2(100,100)
		images.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.set("theme_override_colors/font_color", Color("000000"))
		label_name.set("theme_override_colors/font_color", Color("000000"))
		label.text = "Total 👑 " + str(loser.wins)
		label_name.text = loser.get_child(0).mon_name
		label.theme = load("res://tylermon/tylermon_theme.tres")
		label_name.theme = load("res://tylermon/tylermon_theme.tres")
		image_mon.texture = sprite_frame.get_frame_texture("idle",0)
		image_mon.modulate = loser.get_child(0).custom_color
		image_mon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image_mon.custom_minimum_size = Vector2(100,100)
		image_mon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
		images.add_child(image_mon)
		var vbox = VBoxContainer.new()
		if loser.get_child(0).buff == true:
			var sprite_hair = loser.get_child(0).get_node("scalable_nodes").get_child(2).get_sprite_frames()
			image_hair.texture = sprite_hair.get_frame_texture("idle",0)
			image_hair.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			image_hair.custom_minimum_size = Vector2(100,100)
			image_hair.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
			images.add_child(image_hair)
		if loser.get_child(0).cursed == true:
			var sprite_frame_hat = loser.get_child(0).get_node("scalable_nodes").get_child(3).get_sprite_frames()
			image_hat.texture = sprite_frame_hat.get_frame_texture("idle",0)
			image_hat.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			image_hat.custom_minimum_size = Vector2(100,100)
			image_hat.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
			images.add_child(image_hat)
		if loser.get_child(0).smart == true:
			var sprite_frame_glasses = loser.get_child(0).get_node("scalable_nodes").get_child(1).get_sprite_frames()
			image_glasses.texture = sprite_frame_glasses.get_frame_texture("idle",0)
			image_glasses.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			image_glasses.custom_minimum_size = Vector2(100,100)
			image_glasses.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
			images.add_child(image_glasses)
		vbox.add_child(images)
		vbox.add_child(label_name)
		vbox.add_child(label)
		vbox.set("theme_override_constants/separation", 5)
		container.add_child(vbox)	

