extends KinematicBody2D

onready var projectile = preload("res://scenes/shuriken.tscn")
onready var sprite = self.get_node("Sprite")
onready var animation_player = self.get_node("Sprite/AnimationPlayer")

onready var sound_shuriken = get_node("shuriken_sound")
onready var sound_jump = get_node("jump_sound")
onready var sound_rope = get_node("rope_sound")

const FLOOR_NORMAL = Vector2(0, -1)
const RUNSPEED = 750.0
const GRAVITY = 1000.0

signal idle
signal right
signal left
signal jump
signal fall
signal landed
signal rope_started
signal rope_released
signal shot

var speed = Vector2(0,0)
var direction = 1
var is_on_air = false
var is_on_rope = false
var is_running = false
var rope_target_point = Vector2(0,0)
var is_playing = false

var rope_timer = Timer.new()

var shot_timer = Timer.new()
var can_shot = true
var can_rope = true

var p_animation = "idle"
var n_animation = "idle"

func _input(event):
	if is_playing:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			emit_signal("jump")
		elif Input.is_action_just_pressed("rope"):
			emit_signal("rope_started")
		elif Input.is_action_just_released("rope"):
			emit_signal("rope_released")
		elif Input.is_action_just_pressed("shoot"):
			emit_signal("shot")
		elif Input.is_action_just_pressed("right"):
			emit_signal("right")
		elif Input.is_action_just_pressed("left"):
			emit_signal("left")
		elif Input.is_action_just_released("right") or Input.is_action_just_released("left"):
			if Input.is_action_pressed("right"):
				emit_signal("right")
			elif Input.is_action_pressed("left"):
				emit_signal("left")
			else:
				emit_signal("idle")

func compute_animation(previous = ""):
	p_animation = previous if previous != "" else p_animation
	n_animation = "idle"
	if is_on_air or not is_on_floor():
		n_animation = "jump"
	elif speed.x != 0:
		n_animation = "run"
	if p_animation != n_animation:
		p_animation = n_animation
		animation_player.play(n_animation)

func idle_handler():
	is_running = false
	speed.x = 0
	compute_animation()

func right_handler():
	is_running = true
	is_on_rope = false
	direction = 1
	speed.x = RUNSPEED
	compute_animation()

func left_handler():
	is_running = true
	is_on_rope = false
	direction = -1
	speed.x = -RUNSPEED
	compute_animation()

func jump_handler():
	sound_jump.play()
	speed.y = -GRAVITY
	fall_handler()

func fall_handler():
	is_on_air = true
	# When the fall begins, if the character is already accelerated down, restart the speed on the y-axis to 0
	if speed.y > 0:
		speed.y = 0
	compute_animation()

func landed_handler():
	is_on_air = false
	if not is_running:
		emit_signal("idle")
	else:
		compute_animation()

func rope_started_handler():
	var limits = 2 * get_viewport_rect().size
	var destination = get_local_mouse_position()
	var alfa = atan(destination.y/destination.x)
	if destination.y > 0:
		destination.y += limits.y/2
	else:
		destination.y -= limits.y/2
	destination.x = destination.y/tan(alfa)
	destination = to_global(destination)
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(to_global(Vector2(0,0)), destination, [self])
	if result:
		rope_timer.start()
		is_on_rope = true
		is_on_air = true
		rope_target_point = result.position
		direction = -1 if (self.position.x >= rope_target_point.x) else 1
		sound_rope.play()
		animation_player.play("rope")

func rope_released_handler():
	is_on_rope = false
	if is_on_floor():
		is_on_air = false
	if not Input.is_action_pressed("right") or not Input.is_action_pressed("left"):
		if Input.is_action_pressed("right"):
			emit_signal("right")
		elif Input.is_action_pressed("left"):
			emit_signal("left")
		else:
			emit_signal("idle")

func shot_handler():
	if can_shot:
		can_shot = false
		shot_timer.start()
		var p = projectile.instance()
		p.init(Vector2(direction,0), self.position, self)
		get_parent().add_child(p)
		sound_shuriken.play()
		animation_player.play("shoot") # When the animation ends, the callback will be executed

func _process(delta):
	if is_on_floor() and is_on_air:
		emit_signal("landed")
	elif not is_on_floor() and not is_on_air:
		emit_signal("fall")
	sprite.set_flip_h(true if direction == -1 else false)
	
	if is_playing and Network.websocket != null:
		Network.websocket.send(JSON.print({
			"type": 7,
			"payload": {
				"playerId": Network.playerId,
				"position": {
					"x": position.x,
					"y": position.y,
				},
				"directionId": direction,
				"state": "P"
			}
		}))

func _physics_process(delta):
	if not is_on_floor():
		speed.y += delta * GRAVITY
	if is_on_ceiling():
		speed.y = 0
	if is_on_rope:
		var auxspeed = Vector2(rope_target_point.x - to_global(Vector2(0,0)).x, rope_target_point.y - to_global(Vector2(0,0)).y)
		speed = auxspeed.normalized() * 1.5 * RUNSPEED
	move_and_slide(speed, FLOOR_NORMAL)
	update()

func _draw():
	if(is_on_rope):
		draw_line(Vector2(0, 0), to_local(rope_target_point), Color(0,0,0), 5)

func on_shot_timer_timeout():
	can_shot = true
	
func on_rope_timer_timeout():
	emit_signal("rope_released")
	
func _ready():
	connect("idle", self, "idle_handler")
	connect("right", self, "right_handler")
	connect("left", self, "left_handler")
	connect("jump", self, "jump_handler")
	connect("fall", self, "fall_handler")
	connect("landed", self, "landed_handler")
	connect("rope_started", self, "rope_started_handler")
	connect("rope_released", self, "rope_released_handler")
	connect("shot", self, "shot_handler")
	animation_player.connect("animation_finished", self, "compute_animation")
	
	shot_timer.set_one_shot(true)
	shot_timer.set_wait_time(1.5)
	shot_timer.connect("timeout", self, "on_shot_timer_timeout")
	add_child(shot_timer)
	
	rope_timer.set_one_shot(true)
	rope_timer.set_wait_time(1)
	rope_timer.connect("timeout", self, "on_rope_timer_timeout")
	add_child(rope_timer)
