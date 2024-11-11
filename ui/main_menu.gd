extends Control

@export var music: AudioStream


@onready var start: Button = %Start
@onready var credits: Button = %Credits
@onready var settings: Button = %Settings
@onready var quit: Button = %Quit
@onready var label: Label = $Label


func _ready() -> void:
	label.text = tr("MAIN_LABEL")
	MusicManager.play(music)
	start.pressed.connect(_on_start_pressed)
	settings.pressed.connect(_on_settings_pressed)
	quit.pressed.connect(get_tree().quit)


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/lobby.tscn")


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/settings_menu.tscn")
