extends Control

@export var sfx: AudioStream

@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var back: Button = %Back


func _ready() -> void:
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.drag_ended.connect(_on_sfx_volume_changed)
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://ui/main_menu.tscn"))
	update_slider()

func _on_music_volume_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))
	save_config()

func _on_sfx_volume_changed(value_changed: bool) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(sfx_slider.value))
	AudioManager.play_stream(sfx)
	save_config()

func update_slider() -> void:
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))

func save_config() -> void:
	var config = ConfigFile.new()
	config.set_value("Audio", "Music", music_slider.value)
	config.set_value("Audio", "SFX", sfx_slider.value)
	config.save("user://settings.cfg")
