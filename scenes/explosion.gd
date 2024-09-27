extends Hitbox

@export var impulse: float = 500
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	var player_scene = Game.get_current_player().local_scene
	if player_scene:
		var distance = global_position.distance_to(player_scene.global_position)
		distance = clamp(distance, 0, 500)
		distance = (500 - distance) / 10
		CameraManager.shake(distance)
	else:
		CameraManager.shake(20)
	if not multiplayer.is_server():
		return
	body_entered.connect(_on_body_entered)
	await animation_player.animation_finished
	queue_free()


		
func _on_body_entered(body: Node) -> void:
	if body.has_method("push"):
		body.push(global_position.direction_to(body.global_position), impulse)
