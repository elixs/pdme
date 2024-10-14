extends CharacterBody2D


@export var speed := 300
@export var acceleration := 4000
@export var gravity := 600
@export var is_global := false
@export var blood_fx : PackedScene

var target: Node2D


@onready var detection_area: Area2D = $DetectionArea
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	if not is_global:
		if multiplayer.is_server():
			detection_area.body_entered.connect(_on_body_entered)
			detection_area.body_exited.connect(_on_body_exited)
	await get_tree().create_timer(0.1).timeout
	collision_shape_2d.disabled = false

func _physics_process(delta: float) -> void:
	if is_global:
		var closest = null
		var closest_distance_squared = 0
		for player in Game.players:
			var player_distance_squared = (player.local_scene.global_position - global_position).length_squared()
			if not closest or player_distance_squared < closest_distance_squared:
				closest = player.local_scene
				closest_distance_squared = player_distance_squared
		target = closest
	if not multiplayer.is_server():
		return
	if not is_on_floor():
		velocity.y += gravity * delta
	if target:
		var direction = sign(target.global_position.x - global_position.x)
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
	move_and_slide()

func take_damage(damage: int) -> void:
	spawn_fx.rpc()
	queue_free()

func _on_body_entered(body: Node) -> void:
	var player = body as Player
	if player:
		set_target(player)


func _on_body_exited(body: Node) -> void:
	if body == target:
		set_target(null)

func set_target(value: Node2D) -> void:
	target = value
	#var path = target.get_path() if target else null
	#set_target_remote.rpc(path)

#func set_target_remote(value: EncodedObjectAsID):
@rpc("any_peer", "reliable")
func set_target_remote(target_path):
	if target_path:
		target = get_node(target_path)
	else:
		target = null


@rpc("any_peer", "reliable", "call_local")
func spawn_fx() -> void:
	if not blood_fx:
		return
	var blood_inst = blood_fx.instantiate()
	blood_inst.global_position = global_position
	get_parent().add_child(blood_inst)
