extends Area2D


func _ready() -> void:
	if multiplayer.is_server():
		body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	var player = body as Player
	if player:
		LevelManager.next_level()
