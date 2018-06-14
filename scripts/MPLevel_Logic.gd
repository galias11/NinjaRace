extends Node2D
export (int) var level =1
onready var player = get_node("Ninja")
onready var timer_regresivo = get_node("CanvasLayer/Regresiva")
onready var timer_partida = get_node("CanvasLayer/Timer")
onready var clock_gui = get_node("CanvasLayer/Clock")
onready var music = get_node("CanvasLayer/music_race")
onready var panel_end = get_node("CanvasLayer/Replay_Panel")
onready var enemy = preload("res://scenes/Enemy.tscn")

const OUT = -600
const IN = 80

var ss = 0
var mm = 0

var enemiesDic = {}

func _onUpdateEnemies(data):
	for e in data:
		if enemiesDic.has(str(e.playerId)):
			var aux = enemiesDic[str(e.playerId)]
			aux.position = Vector2(e.position.x, e.position.y)

func _onFinishGame(data):
	var finished = false
	var idw = null
	var minTime
	for e in data:
		if str(e.status) == "C":
			if not finished:
				finished = true
				minTime = e.time
				idw = e.playerId
			elif e.time < minTime:
				minTime = e.time
				idw = e.playerId
	
	var ganador
	if enemiesDic.has(str(idw)):
		ganador = enemiesDic[str(idw)].get_node("Name").text
	else:
		ganador = "Tu"
	get_node("CanvasLayer/Replay_Panel/Nombre").text = ganador
	get_node("CanvasLayer/Replay_Panel/Tiempo").text = get_time()
	displayResults()

func _ready():
	Network.connect("updateEnemies", self, "_onUpdateEnemies")
	Network.connect("finishGame", self, "_onFinishGame")

#Start Race
func _on_Regresiva_timeout():
	for e in MPLevelLoader.enemies:
		var newEnemy = enemy.instance()
		self.add_child(newEnemy)
		newEnemy._set_enemy(e.nick ,e.avatarId - 1, MPLevelLoader.arr_colors[int(e.colorId) - 1])
		newEnemy.z_index = 3
		newEnemy._set_position(player.position.x, player.position.y)
		enemiesDic[str(e.playerId)] = newEnemy

	player.visible = true
	player.is_playing = true
	timer_partida.start()
	clock_gui.visible = true
	music.play()
	timer_regresivo.queue_free()

func displayResults():
	timer_partida.stop()
	player.idle_handler()
	player.is_playing = false
	panel_end.rect_position.y = IN

#End Race
func _on_Goal_body_entered(body):
	if body.is_in_group("player"):
		displayResults()
		Network.websocket.send(JSON.print({
			"type": 7,
			"payload": {
				"playerId": Network.playerId,
				"position": { "x": 0, "y": 0 },
				"directionId": 0,
				"state": "F"
			}
		}))

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
	MPLevelLoader.finishGame()
	get_tree().change_scene("res://scenes/NR_Menu.tscn")

func _on_Replay_pressed():
	get_tree().change_scene("res://scenes/Levels_Single/Level1.tscn")