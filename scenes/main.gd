extends Node2D

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	LevelManager.change_level.rpc(0)
