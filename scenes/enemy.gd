extends CharacterBody2D


@export var speed := 300
@export var acceleration := 4000
@export var gravity := 600
@export var is_global := false

var target: Node2D


@onready var detection_area: Area2D = $DetectionArea

func _ready() -> void:
	if not is_global:
		if multiplayer.is_server():
			detection_area.body_entered.connect(_on_body_entered)
			detection_area.body_exited.connect(_on_body_exited)


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
