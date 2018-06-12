extends KinematicBody2D

onready var sprite = self.get_node("Sprite")
const SPEED = 1500
const LIFETIME = 1.5
var direction = Vector2(1, 0)
var timer = Timer.new()
var col

func on_timeout():
	self.queue_free()

func init(direction, position, player):
	self.direction = direction
	self.position = position + Vector2(0,80)
	self.add_collision_exception_with(player)

func _ready():
	timer.set_one_shot(true)
	timer.set_wait_time(LIFETIME)
	timer.connect("timeout", self, "on_timeout")
	timer.start()
	add_child(timer)
	# Como el sprite esta rotado 90 grados, es necesario hacer un flip v en vez de un flip h
	sprite.set_flip_v(true if direction.x == -1 else false)

func _physics_process(delta):
	col = move_and_collide(Vector2(direction.x * 30, 0))
	if col and col.collider.is_in_group("destroyable"):
		col.collider.queue_free()
		self.queue_free()