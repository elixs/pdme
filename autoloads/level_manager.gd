extends Node


@export var main_menu_scene: PackedScene
@export var credits_scene: PackedScene
@export var levels: Array[PackedScene]

@export var current_level: int = 0

@rpc("any_peer", "call_local", "reliable")
func change_level(level_index: int) -> void:
	if level_index < levels.size():
		get_tree().change_scene_to_packed(levels[level_index])
		current_level = level_index

func next_level() -> void:
	change_level.rpc(current_level + 1)


func go_to_menu() -> void:
	if not main_menu_scene:
		return
	get_tree().change_scene_to_packed(main_menu_scene)


func go_to_credits() -> void:
	if not credits_scene:
		return
	get_tree().change_scene_to_packed(credits_scene)
