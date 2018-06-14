extends Node2D

onready var animation = get_node("Camera2D/AnimationPlayer")
onready var sfx_gong = get_node("Camera2D/Gong")
onready var sfx_transition = get_node("Camera2D/Transition")
onready var sfx_level = get_node("Camera2D/Level")

var new_nombre = "Player"
var new_mask = 1
var new_color = 1 


func _ready():
	if Network.is_connected:
		var panel = get_node("Main_Menu/Panel_Login")
		panel.rect_position = Vector2(0, -2000)	

func getEachMPLevelData():
	var result = Network.getLevelData()
	if result.has("error"):
		print("Error al recibir los datos de los niveles multi")
	
	var levels = result.payload.levelData
	
	get_node("MP_Menu/Niveles/MP1/Players").text = str(levels[0].waitingPlayers)
	get_node("MP_Menu/Niveles/MP2/Players").text = str(levels[1].waitingPlayers)
	get_node("MP_Menu/Niveles/MP3/Players").text = str(levels[2].waitingPlayers)
	get_node("MP_Menu/Niveles/MP4/Players").text = str(levels[3].waitingPlayers)
	get_node("MP_Menu/Niveles/MP5/Players").text = str(levels[4].waitingPlayers)

# Login Functions
func _print_error(error):
	var nodo = get_node("Main_Menu/Panel_Login/Error")
	nodo.text = error
	nodo.visible = true
	
#Login
func _on_Login_pressed():
	var panel = get_node("Main_Menu/Panel_Login")
	var user = panel.get_node("User").text
	var passw = panel.get_node("Pass").text
	var response = Network.connect_user("/login", user, passw)
	if(response.has("error")):
		_print_error(response.error.text)
	else:
		get_node("Main_Menu/Panel_Login/Error").visible = false
		panel.get_node("Login").disabled = true
		panel.get_node("Register").disabled = true
		panel.get_node("Forgot_Pass").disabled = true
		Network.is_connected = true
		_transition_login()
	
#Register
func _on_Register_pressed():
	var panel = get_node("Main_Menu/Panel_Login")
	var user = panel.get_node("User").text
	var passw = panel.get_node("Pass").text
	var response = Network.connect_user("/register", user, passw)
	if(response.has("error")):
		_print_error(response.error.text)
	else:
		response = Network.connect_user("/login", user, passw)
		if(response.has("error")):
			_print_error(response.error.text)
		else:
			get_node("Main_Menu/Panel_Login/Error").visible = false
			panel.get_node("Login").disabled = true
			panel.get_node("Register").disabled = true
			panel.get_node("Forgot_Pass").disabled = true
			Network.is_connected = true
			_transition_login()
	
#Forgot Password Button
func _on_Forgot_Pass_toggled(button_pressed):
	if button_pressed:
		_print_error("No te acordas la contraseña??")
	else:
		_print_error("")


#     Transicion de Escenas
#Login_Transition
func _transition_login():
	animation.play("login_to_main")
#Single_Player_Transition

func _on_VolverSP_pressed():
	animation.play_backwards("main_to_SP")
	sfx_transition.play()
#Multi_Player_Transition
func _on_Multijugador_pressed():
	getEachMPLevelData()
	animation.play("main_to_MP")
	sfx_gong.play()
func _on_VolverMP_pressed():
	animation.play_backwards("main_to_MP")
	sfx_transition.play()
#Options_Transition
func _on_Opciones_pressed():
	animation.play("main_to_options")
	sfx_gong.play()
func _on_VolverOPT_pressed():
	animation.play_backwards("main_to_options")
	sfx_transition.play()
#Waiting_Transition


#Save Player Information Changes
func _on_Save_pressed():
	new_nombre = get_node("Options_Menu/Player_info/LineEdit").text
	new_color = get_node("Options_Menu/Player_info").current_color
	new_mask = get_node("Options_Menu/Player_info").current_frame
	print("SAVED: ", new_nombre, new_mask, new_color)
	_on_VolverOPT_pressed()


func _on_Jugar_pressed():
	var levels = Network.getLevelData().payload.levelData
	
	if levels[0].has("personalRecord"):
		get_node("SP_Menu/Niveles/SP1/Label").text = str(ceil(int(levels[0].personalRecord) / 1000))
	if levels[1].has("personalRecord"):	
		get_node("SP_Menu/Niveles/SP2/Label").text = str(ceil(int(levels[1].personalRecord) / 1000))
	if levels[2].has("personalRecord"):
		get_node("SP_Menu/Niveles/SP3/Label").text = str(ceil(int(levels[2].personalRecord) / 1000))
	if levels[3].has("personalRecord"):
		get_node("SP_Menu/Niveles/SP4/Label").text = str(ceil(int(levels[3].personalRecord) / 1000))
	if levels[4].has("personalRecord"):
		get_node("SP_Menu/Niveles/SP5/Label").text = str(ceil(int(levels[4].personalRecord) / 1000))

	
	animation.play("main_to_SP")
	sfx_gong.play()

#Load Single Player Levels
#Load Level 1
func _on_SP1_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		get_tree().change_scene("res://scenes/Levels_Single/Level1.tscn")
#Load Level 2
func _on_SP2_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		get_tree().change_scene("res://scenes/Levels_Single/Level2.tscn")
#Load Level 3
func _on_SP3_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		get_tree().change_scene("res://scenes/Levels_Single/Level3.tscn")
#Load Level 4
func _on_SP4_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		get_tree().change_scene("res://scenes/Levels_Single/Level4.tscn")
#Load Level 5
func _on_SP5_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		get_tree().change_scene("res://scenes/Levels_Single/Level5.tscn")

func loadMPLevel(data):
	var levelId = int(data[0])
	var nick = data[1]
	var avatarId = data[2]
	var colorId = data[3]
	# Se une a la cola del nivel indicado y espera la respuesta para crear el websocket
	var response = Network.joinQueue(levelId, nick, avatarId, colorId)
	# Datos del websocket
	var wsport = response.payload.sessionData.sessionPort
	var token = response.payload.sessionData.sessionToken
	# Crea un nuevo websocket
	Network.createWebsocket(self)
	# Inicializa el websocket en el puerto indicado por el servidor
	Network.websocket.start(Network.HOST, wsport)
	# Almacena el id del nivel a cargar
	MPLevelLoader.levelId = levelId
	# Envia los datos de validación del websocket al servidor
	return Network.websocket.send(JSON.print({
		"type": 0,
		"payload": {
			"sessionToken": token,
			"playerId": Network.playerId,
			"playerToken": Network.token
		}
	}))

func _go_to_wait(levelId):
	animation.play("MP_to_Waiting")
	sfx_gong.play()
	var th = Thread.new()
	print(new_nombre, new_mask, new_color)
	th.start(self, "loadMPLevel", [levelId, new_nombre, new_mask + 1, 1 + new_color])

# Cancelar MP
func _on_Volver_Wait_pressed():
	Network.leaveQueue()
	animation.play_backwards("MP_to_Waiting")
	sfx_transition.play()

#Load Multi Player Levels
#Load Level 1
func _on_MP1_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		_go_to_wait(1)
#Load Level 2
func _on_MP2_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		_go_to_wait(2)
#Load Level 3
func _on_MP3_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		_go_to_wait(3)
#Load Level 4
func _on_MP4_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		_go_to_wait(4)
#Load Level 1
func _on_MP5_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		_go_to_wait(5)
