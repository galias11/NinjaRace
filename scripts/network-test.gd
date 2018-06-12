extends Node

func _on_ws_message(message):
	print(message)

func joinQueueHandle(data):
	var levelId = int(data[0])
	var nick = data[1]
	var avatarId = data[2]
	var colorId = 1
	var response = Network.joinQueue(levelId, nick, avatarId, colorId)
	var port = response.payload.sessionData.sessionPort
	var token = response.payload.sessionData.sessionToken
	# Crea un nuevo websocket
	var websocket = preload('./websocket.gd').new(self)
	# Inicializa el websocket en el puerto indicado por el servidor
	websocket.start('192.168.0.113', port)
	# Indica la función que manejara los mensajes del websocket
	websocket.set_reciever(self,'_on_ws_message')
	
	OS.delay_msec(500)
	
	websocket.send(JSON.print({
		"type": 0,
		"payload": {
			"sessionToken": token,
			"playerId": Network.playerId,
			"playerToken": Network.token
		}
	}))
	
	OS.delay_msec(7000)
	
	websocket.send(JSON.print({
		"type": 5,
		"payload": {
			"playerId": Network.playerId
		}
	}))

func _ready():
	var connectResult = Network.connect_user("/login", "user@example.com", "user")
	if(connectResult.has("error")):
		print("Error al conectar: ", connectResult)
	print(Network.getLevelData(1))
	#Network.registerSPRecord(1, 10)
	var disconnectResult = Network.connect_user("/logout")
	if(disconnectResult.has("error")):
		print("Error al desconectar: ", disconnectResult)
	#var connectResult = Network.connect_user("/login", "user2@example.com", "user")
	#if(connectResult.has("error")):
	#	print("Error al conectar: ", connectResult)
	#	return false
	#var th = Thread.new()
	#th.start(self, "joinQueueHandle", [1,"hola",4])
	#print("waita")
	#OS.delay_msec(1000)	
	#Network.leaveQueue(1)
	#th.wait_to_finish()
	#print(th.is_active())
	
	#var disconnectResult = Network.connect_user("/logout")
	#if(disconnectResult.has("error")):
	#	print("Error al desconectar: ", disconnectResult)
	#	return false
	
	#print("getLevelData -> started")
	#if getLevelDataTest(1):
	#	print("getLevelData -> success")
	#else:
	#	print("getLevelData -> failed")
	#print("joinQueue -> started")
	#if joinQueueTest(1,"Hola como estas", 2):
	#	print("joinQueue -> success")
	#else:
	#	print("joinQueue -> failed")
		
	pass


	
func getLevelDataTest(levelId = null):
	var connectResult = Network.connect_user("/login", "user@example.com", "user")
	if(connectResult.has("error")):
		print("Error al conectar: ", connectResult)
		return false
	var levelDataResult = Network.getLevelData(levelId)
	if(levelDataResult.has("error")):
		print("Error al requerir datos del nivel: ", levelDataResult)
		return false
	var disconnectResult = Network.connect_user("/logout")
	if(disconnectResult.has("error")):
		print("Error al desconectar: ", disconnectResult)
		return false
	return true
	
func joinQueueTest(levelId, nick, avatarId):
	var connectResult = Network.connect_user("/login", "user@example.com", "user")
	if(connectResult.has("error")):
		print("Error al conectar: ", connectResult)
		return false
	var joinQueueResut = Network.joinQueue(levelId, nick, avatarId)
	if(joinQueueResut.has("error")):
		print("Error al unir a la cola: ", joinQueueResut)
		return false
	var disconnectResult = Network.connect_user("/logout")
	if(disconnectResult.has("error")):
		print("Error al desconectar: ", disconnectResult)
		return false
	return true
	