extends Node

var target = [KEY_2, KEY_5, KEY_7, KEY_1]
var current_key = 0

func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
	var iek = event as InputEventKey
	if iek and iek.pressed:
		if iek.physical_keycode == target[current_key]:
			Debug.log("%d pressed" % iek.physical_keycode)
			current_key += 1
			if current_key == target.size():
				Debug.log("finished")
				current_key = 0
		else:
			current_key = 0
			#Debug.log("oh no")
