extends Control

# multiple areas overlapping causing multiple presses (login screen and keypad)
# transition between screens without speghetti

func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)


func _process(_delta):
	pass


