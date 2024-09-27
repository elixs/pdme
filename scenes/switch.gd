extends Area2D

var player_inside: Player

@export var door: Door
@export var role: Statics.Role


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	for player in Game.players:
		if player.role == role:
			modulate = player.color
			return


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("action") and player_inside:
		if door:
			door.open()


func _on_body_entered(body: Node) -> void:
	var player = body as Player
	if player and player.is_multiplayer_authority() and \
		Game.get_player(player.id).role == role:
		player_inside = player


func _on_body_exited(body: Node) -> void:
	if body == player_inside:
		player_inside = null
