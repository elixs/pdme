extends Node

func shake(strength: float = 10, duration: float = 0.2, steps: int = 6) -> void:
	var tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	var step_duration = duration / steps
	for step in steps:
		tween.tween_property(get_viewport().get_camera_2d(), "offset", _get_random_vector(strength), step_duration)
	tween.tween_property(get_viewport().get_camera_2d(), "offset", Vector2.ZERO, step_duration)


func _get_random_vector(length: float) -> Vector2:
	return Vector2(randf(), randf()) * length
