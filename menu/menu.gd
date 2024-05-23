extends Node3D

@onready var camera: Camera3D = $camera
@onready var timer: Timer = $timer
@onready var spin_timer: Timer = $spin_timer
@onready var title: Node3D = $title
@onready var logo: Node3D = $logo_origin
@onready var thumbnail: Sprite3D = $thumbnail
@onready var projector: MeshInstance3D = $projector

var selecting: bool = false
var spinning: bool = false

var transition_speed: float = 7.0
var spin_speed: float = 6.0

var final_position: Vector3 = Vector3(-14, 10, -14)

var thumbnails: Array = [
	load("res://menu/crushtris_thumbnail.png"),
	load("res://menu/epsilon_thumbnail.png"),
	load("res://menu/crushtris_thumbnail.png")
]

func _ready() -> void:
	timer.timeout.connect(_timeout)
	spin_timer.timeout.connect(_spin_timeout)
	
func _physics_process(delta: float) -> void:
	if selecting:
		projector.rotate(Vector3.UP, 0.1 * 0.1 * delta)
		projector.rotate(Vector3.RIGHT, 0.2 * 0.1 * delta)
		projector.rotate(-Vector3.FORWARD, 0.3 * 0.1 * delta)
		camera.transform.origin = camera.transform.origin.move_toward(final_position, transition_speed * delta)
		
	if spinning:
		logo.rotate(Vector3.UP, spin_speed * delta)
	else:
		logo.basis = logo.basis.slerp(Basis(), 5.5 * delta)
		
	camera.look_at(Vector3(0, 2, 0), Vector3.UP)
	
func _timeout() -> void:
	selecting = true
	spinning = true
	title.get_node("animator").play("skooch_out")
	spin_timer.start(1.9)
	get_node("animator").play("stabilize")

func _spin_timeout() -> void:
	spinning = false
	title.get_node("animator").play("skooch_in")

	
	#await get_tree().create_timer(2.5).timeout
	#for thumbnail_texture in thumbnails:
		#thumbnail.texture = thumbnail_texture
		#get_node("animator").queue("pop_out")
