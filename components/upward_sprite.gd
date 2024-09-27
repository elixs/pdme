class_name UpwardSprite
extends Sprite2D


func _process(delta: float) -> void:
	var shoud_flip = abs(global_rotation) >= PI / 2
	if shoud_flip and sign(global_scale.y) != -1:
		global_scale = Vector2(1, -1)
	elif not shoud_flip and sign(global_scale.y) != 1:
		global_scale = Vector2(1, -1)
