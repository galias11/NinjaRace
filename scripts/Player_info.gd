extends Node2D

const RED = "eb1616"
const ORANGE = "eb6f16"
const BLUE = "163ceb"
const GREEN = "67eb16"
const YELLOW = "d5eb16"
const PURPLE = "c116eb"
const BROWN = "492c21"
const WHITE = "ffffff"
var arr_colors = [RED, ORANGE, BLUE, GREEN, YELLOW, PURPLE, BROWN, WHITE]
const COLORS = 7
const FRAMES = 7
var current_color = 0
var current_frame = 0
onready var mask = get_node("Mask")

func _ready():
	mask.modulate = arr_colors[current_color]

func _on_Mask_rwnd_pressed():
	if current_frame>0:
		current_frame-=1
	else:
		current_frame = FRAMES
	mask.frame = current_frame

func _on_Mask_fwrd_pressed():
	if current_frame<FRAMES:
		current_frame+=1
	else:
		current_frame=0
	mask.frame = current_frame

func _on_Color_fwrd_pressed():
	if current_color<COLORS:
		current_color+=1
	else: 
		current_color=0
	mask.modulate=arr_colors[current_color]


func _on_Color_rwnd_pressed():
	if current_color>0:
		current_color-=1
	else: 
		current_color=COLORS
	mask.modulate=arr_colors[current_color]
