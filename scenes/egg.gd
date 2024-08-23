extends Hitbox


@export var speed = 300


@rpc("any_peer", "call_local", "reliable")
func setup(id: int) -> void:
	set_multiplayer_authority(id)


func _physics_process(delta: float) -> void:
	var velocity = speed * transform.x
	position += velocity * delta
