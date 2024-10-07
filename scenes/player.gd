class_name Player
extends CharacterBody2D

@export var id := 1
@export var speed := 400
@export var jump_speed := 400
@export var acceleration := 4000
@export var gravity := 600
@export var guns : Array[PackedScene]
@export var gun_index = 0:
	set(value):
		var last_gun_index = gun_index
		gun_index = value
		if last_gun_index != gun_index:
			_spawn_current_gun()


var _sleeping := false
var _players_inside: Array[Player] = []
var _gun_scene: Gun

@onready var input_synchronizer: InputSynchronizer = $InputSynchronizer
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback : AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
@onready var sleep_timer: Timer = $SleepTimer
@onready var pivot: Node2D = $Pivot
@onready var stats: Stats = $Stats
@onready var hud: HUD = $HUD
@onready var health_bar: ProgressBar = $HealthBar
@onready var sprite_2d: Sprite2D = $Pivot/Sprite2D
@onready var camera_2d: Camera2D = $Camera2D
@onready var resurrect_area: Area2D = $ResurrectArea
@onready var resurrect_timer: Timer = $ResurrectTimer
@onready var resurrect_progress_bar: TextureProgressBar = $ResurrectProgressBar
@onready var gun_marker: Marker2D = $Pivot/GunMarker


func _ready() -> void:
	setup(id)
	sleep_timer.timeout.connect(func(): _sleeping = true)
	var player_data: Statics.PlayerData = Game.get_player(id)
	sprite_2d.modulate = player_data.color
	stats.health_changed.connect(_on_health_changed)
	hud.health = stats.health
	health_bar.value = stats.health
	hud.visible = is_multiplayer_authority()
	health_bar.visible = not is_multiplayer_authority()
	animation_tree.active = true
	if is_multiplayer_authority():
		resurrect_area.body_entered.connect(_on_dead_player_entered)
		resurrect_area.body_exited.connect(_on_dead_player_exited)
		resurrect_timer.timeout.connect(_on_resurrect_timeout)
	_spawn_current_gun()

func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
	if _players_inside.size():
		if event.is_action_pressed("action"):
			resurrect_timer.start()
		if event.is_action_released("action"):
			resurrect_timer.stop()
			resurrect_progress_bar.value = 0
	if event.is_action_pressed("weapon_1"):
		set_gun(0)
	if event.is_action_pressed("weapon_2"):
		set_gun(1)
	if event.is_action_pressed("weapon_next"):
		next_gun()
	if event.is_action_pressed("weapon_prev"):
		prev_gun()


func _process(delta: float) -> void:
	if not resurrect_timer.is_stopped():
		resurrect_progress_bar.value = 1 - (resurrect_timer.time_left / resurrect_timer.wait_time)
	

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	
	var move_input = input_synchronizer.move_input
	if stats.health <= 0:
		move_input = 0
	velocity.x = move_toward(velocity.x, move_input * speed, acceleration * delta)
	
	if stats.health <= 0:
		move_and_slide()
		return
	
	if is_on_floor() and input_synchronizer.jumping:
		velocity.y = -jump_speed
	
	if input_synchronizer.jumping:
		input_synchronizer.jumping = false
	
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
	camera_2d.enabled = is_multiplayer_authority()


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
	stats.health -= damage


@rpc("any_peer", "call_local", "reliable")
func notify_take_damage(damage: int) -> void:
	Debug.log("damage received: %d" % damage)


func push(direction: Vector2, impulse: float) -> void:
	notify_push.rpc_id(get_multiplayer_authority(), direction, impulse)


# this is needed because we let local player have authority over its velocity
@rpc("any_peer", "call_local", "reliable")
func notify_push(direction: Vector2, impulse: float) -> void:
	velocity = direction * impulse


func _on_health_changed(health) -> void:
	hud.health = health
	health_bar.value = health
	if health <= 0:
		die()


func die():
	playback.travel("death")


@rpc("call_local", "reliable", "any_peer")
func resurrect():
	stats.health = stats.max_health


func _on_dead_player_entered(body: Node) -> void:
	if body == self:
		return
	var player = body as Player
	if player:
		if  player not in _players_inside:
			_players_inside.push_back(player)


func _on_dead_player_exited(body: Node) -> void:
	if body in _players_inside:
		_players_inside.erase(body)
	if _players_inside.is_empty():
		resurrect_timer.stop()
		resurrect_progress_bar.value = 0


func _on_resurrect_timeout() -> void:
	for player in _players_inside:
		if is_instance_valid(player):
			player.resurrect.rpc_id(1)
	resurrect_progress_bar.value = 0


func next_gun() -> void:
	set_gun(gun_index + 1)


func prev_gun() -> void:
	set_gun(gun_index - 1)


func set_gun(index: int) -> void:
	if guns.is_empty():
		return
	var new_index = (index + guns.size()) %  guns.size()
	set_gun_multicast.rpc(new_index)


@rpc("any_peer", "reliable", "call_local")
func set_gun_multicast(index: int) -> void:
	gun_index = index


func _spawn_current_gun() -> void:
	if _gun_scene:
		gun_marker.remove_child(_gun_scene)
		_gun_scene.queue_free()
	if gun_index >= guns.size() or gun_index < 0:
		return
	_gun_scene = guns[gun_index].instantiate()
	_gun_scene.id = id
	_gun_scene.name = "Gun"
	gun_marker.add_child(_gun_scene)


func add_health(value: int) -> void:
	add_health_server.rpc_id(1, value)


@rpc("any_peer", "call_local", "reliable")
func add_health_server(value: int) -> void:
	stats.health += value
