extends Node

# 网络状态枚举
enum NetworkState {
	IDLE,  # 未连接
	HOSTING,  # 作为主机（服务端+客户端）
	CONNECTING,  # 正在连接
	CONNECTED,  # 已连接（作为客户端）
	DISCONNECTED  # 已断开
}

# 当前网络状态
var currentState:NetworkState = NetworkState.IDLE
# 本机 peer ID
var localPeerId:int = 1
# 服务器端口
var serverPort:int = 25001
# 是否为服务端
var isServer:bool = false

# 信号
signal network_state_changed(state:NetworkState)
signal peer_connected(peerId:int)
signal peer_disconnected(peerId:int)
signal connection_failed(reason:String)
signal player_joined(peerId:int, playerName:String)
signal player_left(peerId:int)

# 玩家列表（peerId -> 玩家信息）
var players:Dictionary = {}


# 初始化函数
func _ready():
	# 连接网络信号
	get_tree().get_multiplayer().peer_connected.connect(_on_peer_connected)
	get_tree().get_multiplayer().peer_disconnected.connect(_on_peer_disconnected)
	get_tree().get_multiplayer().connection_failed.connect(_on_connection_failed)

# 创建服务器（作为主机）
func createServer(port:int = 25001, maxPlayers:int = 4):
	# 如果已连接，先断开
	if get_tree().get_multiplayer().has_multiplayer_peer():
		disconnectServer()
	
	serverPort = port
	
	# 创建 ENet 网络连接（Godot 4 使用 ENetMultiplayerPeer）
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, maxPlayers)
	
	if error == OK:
		get_tree().get_multiplayer().multiplayer_peer = peer
		isServer = true
		localPeerId = 1
		currentState = NetworkState.HOSTING
		players[1] = {"name": "Host", "playerId": Game.playerId.p1}
		emit_signal("network_state_changed", currentState)
		print("Server created on port ", port)
	else:
		emit_signal("connection_failed", "Failed to create server: " + str(error))
		print("Failed to create server: ", error)


# 连接到服务器（作为客户端）
func joinServer(ip:String, port:int = 25001):
	# 如果已连接，先断开
	if get_tree().get_multiplayer().has_multiplayer_peer():
		disconnectServer()
	
	serverPort = port
	currentState = NetworkState.CONNECTING
	
	# 创建 ENet 网络连接
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, port)
	
	if error == OK:
		get_tree().get_multiplayer().multiplayer_peer = peer
		print("Connecting to ", ip, ":", port)
	else:
		currentState = NetworkState.IDLE
		emit_signal("connection_failed", "Failed to connect: " + str(error))
		print("Failed to connect: ", error)


# 断开连接
func disconnectServer():
	if get_tree().get_multiplayer().has_multiplayer_peer():
		get_tree().get_multiplayer().multiplayer_peer.close()
		get_tree().get_multiplayer().multiplayer_peer = null
	
	isServer = false
	currentState = NetworkState.DISCONNECTED
	players.clear()
	emit_signal("network_state_changed", currentState)
	print("Disconnected from network")


# 获取当前网络状态
func getState() -> NetworkState:
	return currentState


# 检查是否在线联机模式
func isOnline() -> bool:
	return get_tree().get_multiplayer().has_multiplayer_peer()


# 获取玩家数量
func getPlayerCount() -> int:
	return players.size()


# 获取玩家信息
func getPlayerInfo(peerId:int) -> Dictionary:
	return players.get(peerId, {})


# 获取所有玩家列表
func getAllPlayers() -> Array:
	return players.keys()


# 发送聊天消息（广播）
@rpc("any_peer", "call_remote")
func sendChatMessage(message:String):
	emit_signal("chat_message_received", localPeerId, message)


# 玩家加入通知（RPC，由服务端调用）
@rpc("any_peer", "call_remote")
func notifyPlayerJoined(peerId:int, playerName:String):
	players[peerId] = {"name": playerName}
	emit_signal("player_joined", peerId, playerName)


# 玩家离开通知（RPC，由服务端调用）
@rpc("any_peer", "call_remote")
func notifyPlayerLeft(peerId:int):
	if players.has(peerId):
		var playerName = players[peerId]["name"]
		players.erase(peerId)
		emit_signal("player_left", peerId)


# 网络信号处理

# 有新的 peer 连接
func _on_peer_connected(peerId:int):
	print("Peer connected: ", peerId)
	localPeerId = get_tree().get_multiplayer().get_unique_id()
	
	if isServer:
		# 服务端记录新玩家
		var playerName = "Player " + str(peerId)
		players[peerId] = {"name": playerName, "playerId": Game.playerId.p2 if peerId == 2 else Game.playerId.p1}
		emit_signal("player_joined", peerId, playerName)
		# 通知所有客户端有新玩家加入
		rpc("notifyPlayerJoined", peerId, playerName)
	
	currentState = NetworkState.CONNECTED
	emit_signal("network_state_changed", currentState)


# 有 peer 断开连接
func _on_peer_disconnected(peerId:int):
	print("Peer disconnected: ", peerId)
	
	if isServer:
		# 服务端移除玩家并通知其他客户端
		if players.has(peerId):
			var playerName = players[peerId]["name"]
			players.erase(peerId)
			emit_signal("player_left", peerId)
			rpc("notifyPlayerLeft", peerId)
	
	# 如果是主机断开，所有客户端也断开
	if peerId == 1 && !isServer:
		disconnectServer()
	else:
		currentState = NetworkState.DISCONNECTED
		emit_signal("network_state_changed", currentState)


# 连接失败
func _on_connection_failed():
	print("Connection failed")
	currentState = NetworkState.IDLE
	emit_signal("connection_failed", "Connection timeout")
	emit_signal("network_state_changed", currentState)
