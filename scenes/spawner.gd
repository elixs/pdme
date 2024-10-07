extends MultiplayerSpawner

@onready var marker_2d: Marker2D = $Marker2D
@onready var timer: Timer = $Timer
@export var scene: PackedScene


func _ready() -> void:
	if multiplayer.is_server():
		if scene:
			timer.timeout.connect(_on_timer_timeout)


func _on_timer_timeout() -> void:
	if not scene:
		return
	var scene_inst = scene.instantiate()
	scene_inst.global_position = marker_2d.global_position
	add_child(scene_inst, true)
