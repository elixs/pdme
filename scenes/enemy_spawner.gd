extends MultiplayerSpawner

@onready var marker_2d: Marker2D = $Marker2D
@onready var timer: Timer = $Timer
@export var enemy_scene: PackedScene

func _ready() -> void:
	if multiplayer.is_server():
		if enemy_scene:
			#add_spawnable_scene(enemy_scene.resource_path)
			timer.timeout.connect(_on_timer_timeout)


func _on_timer_timeout() -> void:
	if not enemy_scene:
		return
	var enemy_inst = enemy_scene.instantiate()
	enemy_inst.global_position = marker_2d.global_position
	add_child(enemy_inst, true)
