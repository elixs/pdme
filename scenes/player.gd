extends CharacterBody2D

@export var id := 1
@export var speed := 400
@export var jump_speed := 400
@export var acceleration := 4000
@export var gravity := 600

var _sleeping := false

@onready var input_synchronizer: InputSynchronizer = $InputSynchronizer
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback : AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
@onready var sleep_timer: Timer = $SleepTimer
@onready var pivot: Node2D = $Pivot


func _enter_tree() -> void:
	$Pivot/Gun.id = id


func _ready() -> void:
	setup(id)
	sleep_timer.timeout.connect(func(): _sleeping = true)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	var move_input = input_synchronizer.move_input
	velocity.x = move_toward(velocity.x, move_input * speed, acceleration * delta)
	
	if is_on_floor() and input_synchronizer.jumping:
		input_synchronizer.jumping = false
		velocity.y = -jump_speed
	
	move_and_slide()
	
	_check_sleep()
	
	# animation
	
	if move_input:
		pivot.scale.x = sign(move_input)
	
	if is_on_floor():
		if abs(velocity.x) > 10 or move_input:
			playback.travel("run")
		else:
			if _sleeping:
				playback.travel("sleep")
			else:
				playback.travel("idle")
	else:
		if velocity.y < 0:
			playback.travel("jump")
		else:
			playback.travel("fall")
	

func setup(id: int) -> void:
	set_multiplayer_authority(id, false)
	input_synchronizer.set_multiplayer_authority(id)
	multiplayer_synchronizer.set_multiplayer_authority(id)


func _check_sleep() -> void:
	var moving = velocity.length_squared() > 0
	if moving:
		sleep_timer.stop()
		_sleeping = false
	elif sleep_timer.is_stopped():
		sleep_timer.start()
		
	

#func setup(player_data: Statics.PlayerData) -> void:
	#name = str(player_data.id)
	## set authority to only root node
	#set_multiplayer_authority(player_data.id, false)
	#input_synchronizer.set_multiplayer_authority(player_data.id)
	## make local player authority over movement
	#multiplayer_synchronizer.set_multiplayer_authority(player_data.id)
	#gun.setup(player_data)


func take_damage(damage: int) -> void:
	notify_take_damage.rpc_id(get_multiplayer_authority(), damage)


@rpc("any_peer", "call_local", "reliable")
func notify_take_damage(damage: int) -> void:
	Debug.log("damage received: %d" % damage)


func push(direction: Vector2, impulse: float) -> void:
	notify_push.rpc_id(get_multiplayer_authority(), direction, impulse)

# this is needed because we let local player have authority over its velocity
@rpc("any_peer", "call_local", "reliable")
func notify_push(direction: Vector2, impulse: float) -> void:
	velocity = direction * impulse
