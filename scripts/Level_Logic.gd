extends Node2D
export (int) var level =1
onready var player = get_node("Ninja")
onready var timer_regresivo = get_node("CanvasLayer/Regresiva")
onready var timer_partida = get_node("CanvasLayer/Timer")
onready var clock_gui = get_node("CanvasLayer/Clock")
onready var music = get_node("CanvasLayer/music_race")
onready var panel_end = get_node("CanvasLayer/Replay_Panel")

const OUT = -600
const IN = 80

var ss = 0
var mm = 0

#Start Race
func _on_Regresiva_timeout():
	player.visible = true
	player.is_playing = true
	timer_partida.start()
	clock_gui.visible = true
	music.play()
	timer_regresivo.queue_free()

#End Race
func _on_Goal_body_entered(body):
	if body.is_in_group("player"):
		timer_partida.stop()
		player.idle_handler()
		player.is_playing = false
		panel_end.get_node("Results").text = get_time()
		panel_end.rect_position.y = IN
		check_race_results()
		
		Network.registerSPRecord(level, ss * 1000)

#Check with the server if there is a new Record for the level
#TO_DO:
func check_race_results():
	print("Checking if ", get_time(), "is the best time for level ", level)
	pass

#Time in the game for the record
func get_time():
	if ss<10:
		return str(mm)+":0"+str(ss)
	else:
		return str(mm)+":"+str(ss)

func print_time():
	clock_gui.text = get_time()

func _on_Timer_timeout():
	if ss==59:
		ss=0
		mm+=1
	else:
		ss+=1
	print_time()

#Replay Buttons
func _on_Cancel_pressed():
	get_tree().change_scene("res://scenes/NR_Menu.tscn")

func _on_Replay_pressed():
	get_tree().change_scene("res://scenes/Levels_Single/Level1.tscn")