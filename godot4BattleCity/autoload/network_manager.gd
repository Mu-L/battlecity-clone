extends Node
## 联机管理器（基于 Godot 内置 ENet 多点联机）
## 主机（服务端）= 玩家1，客户端 = 玩家2

# 信号
signal server_started                     # 主机创建房间成功
signal joined_server                      # 客户端成功连接主机
signal player_joined(peer_id: int)        # 主机：有玩家加入房间
signal player_left(peer_id: int)          # 有玩家离开
signal player_input(input: Dictionary)    # 主机：收到客户端（玩家2）的按键
signal connection_failed(reason: String)  # 创建/连接失败

const DEFAULT_PORT := 25001
const MAX_PLAYERS := 2

# 服务器端口
var port := DEFAULT_PORT
# 是否处于联机状态
var online := false

# 是否正在主动断开（避免断开信号重复处理）
var _closing := false


# 初始化函数
func _ready() -> void:
	var mp := multiplayer
	mp.peer_connected.connect(_on_peer_connected)
	mp.peer_disconnected.connect(_on_peer_disconnected)
	mp.connected_to_server.connect(_on_connected_to_server)
	mp.connection_failed.connect(_on_connection_failed)
	mp.server_disconnected.connect(_on_server_disconnected)


# 是否处于联机状态
func is_online() -> bool:
	return online and multiplayer.multiplayer_peer != null


# 是否是主机（服务端）
func is_server() -> bool:
	return is_online() and multiplayer.is_server()


# 是否是客户端
func is_client() -> bool:
	return is_online() and not multiplayer.is_server()


# 创建房间（作为主机）
func host(p_port: int = DEFAULT_PORT) -> bool:
	close()
	var peer := ENetMultiplayerPeer.new()
	if peer.create_server(p_port, MAX_PLAYERS) != OK:
		connection_failed.emit("创建房间失败")
		return false
	multiplayer.multiplayer_peer = peer
	port = p_port
	online = true
	server_started.emit()
	return true


# 加入房间（作为客户端）
func join(ip: String, p_port: int = DEFAULT_PORT) -> bool:
	close()
	var peer := ENetMultiplayerPeer.new()
	if peer.create_client(ip, p_port) != OK:
		connection_failed.emit("连接失败")
		return false
	multiplayer.multiplayer_peer = peer
	port = p_port
	online = true
	return true


# 断开联机
func close() -> void:
	_closing = true
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	online = false
	_closing = false


# 客户端：把本地玩家（玩家2）的按键发给主机
func send_input(input: Dictionary) -> void:
	if is_client():
		_net_player_input.rpc_id(1, input)


# 主机：接收客户端（玩家2）的按键
@rpc("any_peer", "call_remote", "unreliable_ordered")
func _net_player_input(input: Dictionary) -> void:
	if is_server():
		player_input.emit(input)


# 切换场景：单机直接切换；联机时由主机决定并通知所有客户端一起切换
func change_scene(path: String, data: Dictionary = {}) -> void:
	if is_client():
		return
	Game.scene_data = data
	if is_online():
		_net_goto_scene.rpc(path, Game.gameLevel, data)
	get_tree().change_scene_to_file(path)


@rpc("authority", "call_remote", "reliable")
func _net_goto_scene(path: String, level: int, data: Dictionary) -> void:
	Game.gameLevel = level
	Game.scene_data = data
	get_tree().change_scene_to_file(path)


# 网络信号处理

# 主机：有客户端连入
func _on_peer_connected(peer_id: int) -> void:
	if multiplayer.is_server():
		player_joined.emit(peer_id)


# 有玩家断开
func _on_peer_disconnected(peer_id: int) -> void:
	player_left.emit(peer_id)


# 客户端：连接主机成功
func _on_connected_to_server() -> void:
	joined_server.emit()


# 连接失败
func _on_connection_failed() -> void:
	close()
	connection_failed.emit("连接超时或被拒绝")


# 客户端：主机断开，返回主菜单
func _on_server_disconnected() -> void:
	if _closing:
		return
	close()
	get_tree().change_scene_to_file("res://scene/welcome.tscn")
