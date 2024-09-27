class_name Statics
extends Node


const MAX_CLIENTS = 3
const PORT = 5409 # Number between 1024 and 65535.


enum Role {
	NONE,
	ROLE_A,
	ROLE_B,
}


class PlayerData:
	var id: int
	var name: String
	var index: int = 0
	var color: Color
	var role: Role
	var local_scene
	
	func _init(new_id: int, new_name: String, new_index: int = 0, new_role: Role = Role.NONE, new_color: Color = Color.WHITE) -> void:
		id = new_id
		name = new_name
		index = new_index
		role = new_role
		color = new_color
	
	func to_dict() -> Dictionary:
		return {
			"id": id,
			"name": name,
			"index": index,
			"role": role,
		}
