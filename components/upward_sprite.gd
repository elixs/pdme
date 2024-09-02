class_name UpwardSprite
extends Sprite2D

func _process(delta: float) -> void:
	if abs(global_rotation) >= PI / 2:
		scale.y = -1
	else:
		scale.y = 1
