class_name Pickable
extends Area2D

@onready var label: Label = $Label
var player_inside: Player

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	label.hide()


func _input(event: InputEvent) -> void:
	if player_inside and event.is_action_pressed("action"):
		pick()


func pick() -> void:
	destroy_server.rpc_id(1)


@rpc("any_peer", "reliable", "call_local")
func destroy_server() -> void:
	queue_free()


func _on_body_entered(body: Node) -> void:
	var player = body as Player
	if player and player.is_multiplayer_authority():
		player_inside = player
		label.show()


func _on_body_exited(body: Node) -> void:
	if body == player_inside:
		player_inside = null
		label.hide()
