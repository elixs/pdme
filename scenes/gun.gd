class_name Gun
extends Node2D


signal reload_finished

@export var id := 1
@export var bullet_scene: PackedScene
@export var fire_sound: AudioStream
@export var ammo := 10 :
	set(value):
		ammo = value
		if ammo_label:
			ammo_label.text = str(ammo)
@export var max_ammo := 10

@onready var upward_sprite: UpwardSprite = $UpwardSprite
@onready var marker_2d: Marker2D = $Marker2D
@onready var bullet_spawner: MultiplayerSpawner = $BulletSpawner
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var ammo_label: Label = %AmmoLabel


func _ready() -> void:
	setup(id)
	canvas_layer.visible = is_multiplayer_authority()
	ammo = max_ammo
	reload_finished.connect(real_reload)


func _process(delta: float) -> void:
	if is_multiplayer_authority():
		global_rotation = global_position.direction_to(get_global_mouse_position()).angle()


func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
	if event.is_action_pressed("fire"):
		fire.rpc_id(1)
		fire_fx.rpc()
	if event.is_action_pressed("reload"):
		reload.rpc_id(1)


func setup(id) -> void:
	set_multiplayer_authority(id, false)
	multiplayer_synchronizer.set_multiplayer_authority(id)


@rpc("reliable", "any_peer", "call_local")
func fire() -> void:
	if not multiplayer.is_server():
		return
	if not bullet_scene:
		Debug.log("No bullet provided")
		return
	if ammo <= 0:
		return
	ammo -= 1
	var bullet_inst = bullet_scene.instantiate()
	bullet_inst.global_position = marker_2d.global_position
	bullet_inst.global_rotation = global_rotation
	bullet_spawner.add_child(bullet_inst, true)


@rpc("reliable", "call_local")
func fire_fx() -> void:
	var tween = create_tween()
	tween.tween_property(upward_sprite, "position:x", -10, 0.05).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(upward_sprite, "position:x", 0, 0.15)
	AudioManager.play_stream(fire_sound)


@rpc("reliable", "any_peer", "call_local")
func reload() -> void:
	if not multiplayer.is_server():
		return
	reload_fx.rpc()

@rpc("any_peer", "reliable", "call_local")
func reload_fx() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(upward_sprite, "position:y", -20, 0.1)
	tween.tween_property(upward_sprite, "position:y", 10, 0.1)
	tween.tween_property(upward_sprite, "position:y", 0, 0.1)
	await tween.finished
	if multiplayer.is_server():
		reload_finished.emit()


func real_reload() -> void:
	ammo = max_ammo
	
