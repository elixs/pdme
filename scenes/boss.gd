extends Node2D

@export var music: AudioStream
@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
	area_2d.body_entered.connect(_on_body_entered)
	area_2d.body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	MusicManager.accent(music)


func _on_body_exited(body: Node) -> void:
	MusicManager.back()
