extends Area2D

@export var impulse: float = 500


func _ready() -> void:
	if not multiplayer.is_server():
		return
	body_entered.connect(_on_body_entered)


		
func _on_body_entered(body: Node) -> void:
	if body.has_method("push"):
		body.push(global_position.direction_to(body.global_position), impulse)
