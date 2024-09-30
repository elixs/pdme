extends Area2D

@export var explosion_scene: PackedScene

@export var speed = 300


func _ready() -> void:
	if multiplayer.is_server():
		body_entered.connect(_on_body_entered)


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
	explosion.call_deferred()
