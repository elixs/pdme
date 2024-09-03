extends Hitbox

@export var impulse: float = 500
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	if not multiplayer.is_server():
		return
	body_entered.connect(_on_body_entered)
	await animation_player.animation_finished
	queue_free()


		
func _on_body_entered(body: Node) -> void:
	if body.has_method("push"):
		body.push(global_position.direction_to(body.global_position), impulse)
