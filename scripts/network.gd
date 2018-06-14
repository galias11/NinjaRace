extends Node
# Signals for possible states when the connection is being made
signal network_resolving           # Currently resolving the hostname for the given URL into an IP
signal network_connecting          # Currently connecting to server
# Signals for possible results when trying to establish the connection to the server
signal network_connected           # Connection established
signal network_disconnected        # Disconnected from the server
signal network_cant_resolve        # DNS failure: Can’t resolve the hostname for the given 
signal network_cant_connect        # Can’t connect to the server
signal network_connection_error    # Error in HTTP connection
signal network_ssl_handshake_error # Error in SSL handshake
# Signals for possible states when a request is made
signal network_requesting          # Currently sending request
signal network_body                # HTTP body received
# Connection constants
const HOST = "www.evansfelipe.com.ar"
const PORT = 30030
const BASIC_HEADERS = ["User-Agent: Ninja-Race/1.0", "Accept: */*"]
# Connection variables
var http = null
var cookie = null
var is_connected = false

var websocket = null

var playerId = null
var token = null

signal setEnemies(data)
signal syncGame(timestamp)
signal updateEnemies(data)
signal finishGame(data)

func init_network():
	var err = 0
	http = HTTPClient.new()
	err = http.connect_to_host(HOST, PORT)
	# Wait until resolved and connected
	while http.get_status() == HTTPClient.STATUS_CONNECTING or http.get_status() == HTTPClient.STATUS_RESOLVING:
		http.poll()
		OS.delay_msec(50)
	# Connection result
	var status = http.get_status()
	# Disconnected from the server
	if status == HTTPClient.STATUS_DISCONNECTED:
		emit_signal("network_disconnected")
	# DNS failure: Can’t resolve the hostname for the given URL
	elif status == HTTPClient.STATUS_CANT_RESOLVE:
		emit_signal("network_cant_resolve")
	# Can’t connect to the server
	elif status == HTTPClient.STATUS_CANT_CONNECT:
		emit_signal("network_cant_connect")
	# Error in HTTP connection
	elif status == HTTPClient.STATUS_CONNECTION_ERROR:
		emit_signal("network_connection_error")
	# Error in SSL handshake
	elif status == HTTPClient.STATUS_SSL_HANDSHAKE_ERROR:
		emit_signal("network_ssl_handshake_error")
	# Connection established
	elif status == HTTPClient.STATUS_CONNECTED:
		emit_signal("network_connected")
	
func on_network_disconnected():
	print("Network disconnected")
func on_network_cant_resolve():
	print("Network cant resolve")
func on_network_cant_connect():
	print("Network cant connect")
func on_network_connection_error():
	print("Network connection error")
func on_network_ssl_handshake_error():
	print("Network ssl handshake error")
func on_network_connected():
	#print("Connection success")
	pass

func _notification(event):
	if event == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		connect_user("/logout")

func _init():
	connect("network_disconnected", self, "on_network_disconnected")
	connect("network_cant_resolve", self, "on_network_cant_resolve")
	connect("network_cant_connect", self, "on_network_cant_connect")
	connect("network_connection_error", self, "on_network_connection_error")
	connect("network_ssl_handshake_error", self, "on_network_ssl_handshake_error")
	connect("network_connected", self, "on_network_connected")

func getHttp(route, headers):
	init_network()
	headers = BASIC_HEADERS + headers
	headers.append("Content-Type: application/x-www-form-urlencoded")
	if cookie:
		headers.append("Cookie: " + cookie)
	var result = http.request(http.METHOD_GET, route, headers)
	# Keep polling until the request is going on
	while http.get_status() == HTTPClient.STATUS_REQUESTING:
		http.poll()
		OS.delay_msec(50)
	if http.has_response():
		# Get response headers
		var response_headers = http.get_response_headers_as_dictionary()
		if response_headers.has("set-cookie"):
			cookie = str(response_headers["set-cookie"]).split(";")[0]
		var rb = PoolByteArray() # Array that will hold the data
		while http.get_status() == HTTPClient.STATUS_BODY:
			# While there is body left to be read
			http.poll()
			var chunk = http.read_response_body_chunk() # Get a chunk
			if chunk.size() == 0:
			    # Got nothing, wait for buffers to fill a bit
			    OS.delay_usec(1000)
			else:
			    rb = rb + chunk # Append to read buffer
		http.close()
		var json = JSON.parse(rb.get_string_from_ascii())
		if(!(json.error == OK)):
			return "Fatal server error"
		return json.result
	
func postHttp(route, headers, query):
	init_network()
	query = http.query_string_from_dict(query)
	headers = BASIC_HEADERS + headers
	headers.append("Content-Type: application/x-www-form-urlencoded")
	headers.append("Content-Length: " + str(query.length()))
	if cookie:
		headers.append("Cookie: " + cookie)
	var result = http.request(http.METHOD_POST, route, headers, query)
	# Keep polling until the request is going on
	while http.get_status() == HTTPClient.STATUS_REQUESTING:
		http.poll()
		OS.delay_msec(50)
	if http.has_response():
		# Get response headers
		var response_headers = http.get_response_headers_as_dictionary()
		if response_headers.has("set-cookie"):
			cookie = str(response_headers["set-cookie"]).split(";")[0]
		var rb = PoolByteArray() # Array that will hold the data
		while http.get_status() == HTTPClient.STATUS_BODY:
			# While there is body left to be read
			http.poll()
			var chunk = http.read_response_body_chunk() # Get a chunk
			if chunk.size() == 0:
			    # Got nothing, wait for buffers to fill a bit
			    OS.delay_usec(1000)
			else:
			    rb = rb + chunk # Append to read buffer
		http.close()
		var json = JSON.parse(rb.get_string_from_ascii())
		if(!(json.error == OK)):
			return "Fatal server error"
		return json.result

func connect_user(route, email = "", pword = ""):
	var response = postHttp(route, [], {"email": email, "pword": pword})
	if response.has("payload") and response.payload.has("playerData"):
		if response.payload.playerData.has("playerId"):
			playerId = response.payload.playerData.playerId
		if response.payload.playerData.has("token"):
			token = response.payload.playerData.token
	return response
	
func registerSPRecord(levelId, time):
	return postHttp("/updateRecord", [], {
		"levelId": levelId,
		"time": time
	})

func getLevelData(levelId = null):
	var route = "/levelData"
	if(levelId):
		route += "?levelId=" + str(levelId)
	return getHttp(route, [])

func joinQueue(levelId, nick, avatarId, colorId):
	return postHttp("/joinQueue", [], {"levelId": levelId, "nick": nick, "avatarId": avatarId, "colorId": colorId})

func leaveQueue():
	var response = postHttp("/leaveQueue", [], {"queueId": int(0)})
	print("Leave queue response: ", response)

func websocketReceiver(message):
	var msg = JSON.parse(message).result
	if msg.has("type"):
		if msg.type == 2:
			Network.websocket.send(JSON.print({
				"type": 5,
				"payload": {
					"playerId": Network.playerId
				}
			}))
			emit_signal("setEnemies", msg.playersData)
		elif msg.type == 6: # Sync
			emit_signal("syncGame", msg.timeStamp)
		elif msg.type == 7:
			emit_signal("updateEnemies", msg.payload.players)
		else:
			print("Con tipo: ", message)
	else:
		emit_signal("finishGame", msg)

func createWebsocket(ref):
	websocket = preload('./websocket.gd').new(self)
	# Indica la función que manejara los mensajes del websocket
	websocket.set_reciever(self,'websocketReceiver')