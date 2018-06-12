extends Area2D

var offset_x =30
var offset_y = 90
onready var sfx_level = get_tree().get_root().get_node("NR_Menu/Camera2D/Level")
#export (String) var path_to_level = "res://scenes/Levels_Single/Level1"
export (String) var title = "Nivel 1"
var record = "-"

func _ready():
	apply_scale(Vector2(0.9,0.9))
	get_node("Titulo").text = title
	get_node("Label").text = record


func _on_SP1_mouse_entered():
	apply_scale(Vector2(1.25,1.25))
	translate(Vector2(-offset_x,-offset_y))
	sfx_level.play()


func _on_SP1_mouse_exited():
	apply_scale(Vector2(0.8,0.8))
	translate(Vector2(offset_x,offset_y))
