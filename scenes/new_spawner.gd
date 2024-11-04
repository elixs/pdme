@tool
extends Node2D

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var timer: Timer = $Timer
@export var scene: PackedScene
@export var spawn_zone: Rect2
@export var enabled := true


func _ready() -> void:
	if not enabled:
		return
	if multiplayer.is_server():
		if scene:
			timer.timeout.connect(_on_timer_timeout)


func _on_timer_timeout() -> void:
	if not scene:
		return
	var scene_inst = scene.instantiate()
	multiplayer_spawner.add_child(scene_inst, true)
	scene_inst.global_position = get_spawn_location()



func _process(delta: float) -> void:
	queue_redraw()


func _draw():
	draw_rect(spawn_zone, Color.GREEN)


func get_spawn_location() -> Vector2:
	return global_position + Vector2(
		randf_range(
			spawn_zone.position.x,
			spawn_zone.end.x),
		randf_range(
			spawn_zone.position.y,
			spawn_zone.end.y
		)
	)
