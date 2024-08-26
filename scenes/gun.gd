class_name Gun
extends Node2D

@export var bullet_scene: PackedScene
@onready var marker_2d: Marker2D = $Marker2D
@onready var bullet_spawner: MultiplayerSpawner = $BulletSpawner


func _input(event: InputEvent) -> void:
	if owner.is_multiplayer_authority():
		if event.is_action_pressed("fire"):
			fire()


func fire() -> void:
	if not bullet_scene:
		Debug.log("No bullet provided")
		return
	var bullet_inst = bullet_scene.instantiate()
	bullet_inst.global_position = marker_2d.global_position
	bullet_inst.global_rotation = global_rotation
	#bullet_inst.player = get_multiplayer_authority()
	bullet_spawner.add_child(bullet_inst, true)
	bullet_inst.setup.rpc(owner.get_multiplayer_authority())
	#bullet_inst.set_multiplayer_authority(owner.get_multiplayer_authority())
