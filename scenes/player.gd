extends CharacterBody2D

@onready var gun: Node2D = $Gun


func _process(delta: float) -> void:
	if is_multiplayer_authority():
		gun.rotation = gun.global_position.direction_to(get_global_mouse_position()).angle()


func setup(player_data: Statics.PlayerData) -> void:
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)
