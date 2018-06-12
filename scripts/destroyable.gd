extends StaticBody2D
export var size = 1

func _ready():
	self.get_node("Sprite").region_rect = Rect2(Vector2(0,0), Vector2(size * 64, 64))
	self.get_node("CollisionShape2D").scale = Vector2(size,1)
