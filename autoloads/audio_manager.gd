extends Node


func play_stream(stream: AudioStream) -> void:
	if not stream:
		return
	var audio_stream_player = AudioStreamPlayer.new()
	audio_stream_player.stream = stream
	audio_stream_player.bus = "SFX"
	add_child(audio_stream_player)
	audio_stream_player.play()
	await audio_stream_player.finished
	audio_stream_player.queue_free()
