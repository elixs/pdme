extends CharacterBody2D

@export var speed = 400
@export var jump_speed = 400
@export var acceleration = 4000
@export var gravity = 600
@onready var gun: Gun = $Gun


@onready var input_synchronizer: InputSynchronizer = $InputSynchronizer



func _process(delta: float) -> void:
	if is_multiplayer_authority():
		gun.rotation = gun.global_position.direction_to(get_global_mouse_position()).angle()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	var move_input = input_synchronizer.move_input
	velocity.x = move_toward(velocity.x, move_input * speed, acceleration * delta)
	
	if is_on_floor() and input_synchronizer.jumping:
		input_synchronizer.jumping = false
		velocity.y = -jump_speed
	move_and_slide()


func setup(player_data: Statics.PlayerData) -> void:
	name = str(player_data.id)
	
	set_multiplayer_authority(player_data.id)
	input_synchronizer.set_multiplayer_authority(player_data.id)
	gun.set_multiplayer_authority(player_data.id)


func take_damage(damage: int) -> void:
	notify_take_damage.rpc_id(get_multiplayer_authority(), damage)


@rpc("any_peer", "call_local", "reliable")
func notify_take_damage(damage: int) -> void:
	Debug.log("damage received: %d" % damage)

func push(direction: Vector2, impulse: float) -> void:
	notify_take_push.rpc_id(get_multiplayer_authority(), direction, impulse)
	
	
@rpc("any_peer", "call_local", "reliable")
func notify_take_push(direction: Vector2, impulse: float) -> void:
	Debug.log("push")
	velocity += direction * impulse
