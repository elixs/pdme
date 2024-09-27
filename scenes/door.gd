class_name Door
extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func open() -> void:
	open_local.rpc()

@rpc("any_peer", "reliable", "call_local")
func open_local() -> void:
	animation_player.play("open")
