extends Sprite

func _set_enemy(name, mask, color):
	get_node("Name").text = name
	modulate = color
	frame = mask

func _set_position(x,y):
	self.global_position = Vector2(x,y)