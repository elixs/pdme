extends Node2D

@export var gravity := 300.0
@export var item_scene: PackedScene
@onready var ray_cast_2d: RayCast2D = $RayCast2D

func  _physics_process(delta: float) -> void:
	position.y += gravity * delta
	if ray_cast_2d.is_colliding():
		queue_free()
		spawn_item()


func spawn_item() -> void:
	if not item_scene or not multiplayer.is_server():
		return
	var item_inst = item_scene.instantiate()
	item_inst.global_position = global_position
	get_parent().add_child(item_inst)
