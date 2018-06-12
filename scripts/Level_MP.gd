extends Area2D

var offset_x =30
var offset_y = 90
onready var sfx_level = get_tree().get_root().get_node("NR_Menu/Camera2D/Level")
export (String) var title = "Nivel 1"
var players = "1000"

func _ready():
	apply_scale(Vector2(0.9,0.9))
	get_node("Titulo").text = title
	get_node("Players").text = players

func _on_MP1_mouse_entered():
	apply_scale(Vector2(1.25,1.25))
	translate(Vector2(-offset_x,-offset_y))
	sfx_level.play()

func _on_MP1_mouse_exited():
	apply_scale(Vector2(0.8,0.8))
	translate(Vector2(offset_x,offset_y))
