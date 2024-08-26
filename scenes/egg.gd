extends Hitbox


@export var explosion_scene: PackedScene

@export var speed = 300
@export var player: int:
	set(value):
		player = value
		set_multiplayer_authority(player)


func _ready() -> void:
	if is_multiplayer_authority():
		body_entered.connect(_on_body_entered)


@rpc("any_peer", "call_local", "reliable")
func setup(id: int) -> void:
	set_multiplayer_authority(id)


func _physics_process(delta: float) -> void:
	var velocity = speed * transform.x
	position += velocity * delta


func explosion() -> void:
	if not explosion_scene:
		return
	var explosion_inst = explosion_scene.instantiate()
	explosion_inst.global_position = global_position
	get_parent().add_child(explosion_inst, true)
	queue_free()
	


func _on_body_entered(body: Node) -> void:
	Debug.log(body.name)
	explosion()
