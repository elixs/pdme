extends Pickable

@export var health := 20

func pick() -> void:
	super.pick()
	if player_inside:
		player_inside.add_health(health)
