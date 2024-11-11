extends Node


@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var accent_player: AudioStreamPlayer = $AccentPlayer

func play(stream: AudioStream) -> void:
	music_player.stream = stream
	music_player.play()


func accent(stream: AudioStream) -> void:
	accent_player.stream = stream
	accent_player.volume_db = linear_to_db(0)
	accent_player.play()
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", linear_to_db(0.2), 0.2)
	tween.parallel().tween_property(accent_player, "volume_db", linear_to_db(0.8), 0.2)


func back() -> void:
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", linear_to_db(1), 0.5)
	tween.parallel().tween_property(accent_player, "volume_db", linear_to_db(0), 0.5)
	await tween.finished
	accent_player.stop()
