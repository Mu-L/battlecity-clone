extends Node2D

# 坦克选择位置列表（Y坐标）
var posY = [188, 213, 241, 270, 300, 327, 356]

# 当前选择索引
var index = 0

# 菜单模式枚举
enum mode {
	P1, # 单人模式
	P2, # 双人模式
	ONLINE_HOST, # 联机模式 - 创建房间
	ONLINE_JOIN, # 联机模式 - 加入房间
	CONFIGMAP, # 地图编辑器
	SETTING, # 设置
	MAPVIEW # 地图查看
}

# 当前选中的模式
var selectedMode = mode.P1
# 坦克动画节点
@onready var tankAni = $main/tankAni
# 玩家动画节点
@onready var player = $payer
# 提示对话框节点
@onready var tipDialog = $PopupPanel
# 联机对话框节点
@onready var onlineDialog = $OnlineDialog
# IP输入框
@onready var ipInput = $OnlineDialog/VBoxContainer/HBoxContainer/ipInput
# 端口输入框
@onready var portInput = $OnlineDialog/VBoxContainer/HBoxContainer/portInput
# 联机状态标签
@onready var statusLabel = $OnlineDialog/VBoxContainer/statusLabel

@onready var btnHost=$OnlineDialog/VBoxContainer/VBoxContainer2/btnHost
@onready var btnJoin=$OnlineDialog/VBoxContainer/VBoxContainer2/btnJoin

# 初始化函数
func _ready():
	RenderingServer.set_default_clear_color('#000') # 设置背景色为黑色
	player.play("move") # 播放玩家动画
	
	# 连接网络管理器信号
	NetworkManager.network_state_changed.connect(_on_network_state_changed)
	NetworkManager.connection_failed.connect(_on_connection_failed)
	

# 设置当前菜单模式
func setMode(_index):
	tankAni.position.y = posY[index] # 更新坦克选择位置
	if _index == 0:
		selectedMode = mode.P1 # 单人模式
	elif _index == 1:
		selectedMode = mode.P2 # 双人模式
	elif _index == 2:
		selectedMode = mode.ONLINE_HOST # 联机模式 - 创建房间
	elif _index == 3:
		selectedMode = mode.ONLINE_JOIN # 联机模式 - 加入房间
	elif _index == 4:
		selectedMode = mode.CONFIGMAP # 地图编辑器
	elif _index == 5:
		selectedMode = mode.SETTING # 设置
	elif _index == 6:
		selectedMode = mode.MAPVIEW # 地图查看

# 开始游戏或进入对应模式
func startGame():
	if selectedMode in [mode.P1, mode.P2]: # 游戏模式
		if Game.mapList.size() == 0: # 地图为空时提示
			tipDialog.popup_centered() # 弹出提示对话框
			return
		
		var temp = load("res://scene/splash.tscn") # 加载开场场景
		Game.resetData() # 重置游戏数据
		
		if selectedMode == mode.P1:
			Game.mode = Game.gameMode.SINGLE # 设置为单人模式
		elif selectedMode == mode.P2:
			Game.mode = Game.gameMode.DOUBLE # 设置为双人模式
		
		var scene = temp.instantiate() # 实例化场景
		scene.selectLevel = true # 允许选择关卡
		get_tree().root.add_child(scene) # 添加到根节点
		get_tree().current_scene = scene # 设置为当前场景
		queue_free() # 释放当前场景		
	#elif selectedMode == mode.ONLINE_HOST:
		#onlineDialog.popup_centered()
	#elif selectedMode == mode.ONLINE_JOIN:
		#onlineDialog.popup_centered() # 弹出联机对话框
	elif selectedMode == mode.MAPVIEW:
		Game.changeScene("res://scene/map_view.tscn") # 进入地图查看场景
	elif selectedMode == mode.SETTING:
		Game.changeScene("res://scene/setting.tscn") # 进入设置场景
	elif selectedMode == mode.CONFIGMAP:
		Game.changeScene("res://scene/editmap.tscn") # 进入地图编辑器场景

# 创建联机房间（作为主机）
func startOnlineHost():
	if Game.mapList.size() == 0:
		tipDialog.popup_centered()
		return
	
	statusLabel.text = "正在创建房间..."
	
	# 创建服务器
	NetworkManager.createServer(25001, 2)
	
	# 设置联机模式
	Game.mode = Game.gameMode.ONLINE
	Game.resetData()
	
	btnHost.disabled=true
	btnJoin.disabled=true
	
	# 等待连接后进入游戏
	#var temp = load("res://scene/splash.tscn")
	#var scene = temp.instantiate()
#
#
	#scene.selectLevel = true
	#get_tree().root.add_child(scene)
	#get_tree().current_scene = scene
	#queue_free()

# 加入联机房间（作为客户端）
func joinOnlineRoom():
	var ip :String= ipInput.text.strip_escapes()
	var port = int(portInput.text) if portInput.text else 25001

	if ip.is_empty():
		statusLabel.text = "请输入服务器IP"
		return
	
	statusLabel.text = "正在连接到 " + ip + ":" + str(port) + "..."
	
	# 连接到服务器
	NetworkManager.joinServer(ip, port)
	
	# 设置联机模式
	Game.mode = Game.gameMode.ONLINE
	Game.resetData()
	btnHost.disabled=true
	btnJoin.disabled=true

@rpc("any_peer","call_local")
func start():
	# 连接成功后进入游戏
	var temp = load("res://scene/splash.tscn")
	var scene = temp.instantiate()
	scene.selectLevel = true
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	onlineDialog.hide()
	queue_free()

# 网络状态变化处理
func _on_network_state_changed(state):
	match state:
		NetworkManager.NetworkState.HOSTING:
			statusLabel.text = "房间创建成功，等待其他玩家..."
		NetworkManager.NetworkState.CONNECTING:
			statusLabel.text = "正在连接..."
		NetworkManager.NetworkState.CONNECTED:
			statusLabel.text = "连接成功！"
			# 连接成功后进入游戏
			#var temp = load("res://scene/splash.tscn")
			#var scene = temp.instantiate()
			#scene.selectLevel = true
			#get_tree().root.add_child(scene)
			#get_tree().current_scene = scene
			#onlineDialog.hide()
			#queue_free()
			start.rpc()
		NetworkManager.NetworkState.DISCONNECTED:
			statusLabel.text = "连接已断开"
		NetworkManager.NetworkState.IDLE:
			statusLabel.text = ""

# 连接失败处理
func _on_connection_failed(reason):
	statusLabel.text = "连接失败: " + reason

# 输入处理
func _input(_event):
	# 如果联机对话框可见，忽略菜单输入
	if onlineDialog.visible:
		return
	
	# 向上选择
	if Input.is_action_just_pressed("p1_up") || Input.is_action_just_pressed("p2_up"):
		if index > 0:
			index -= 1 # 减少索引
			setMode(index) # 更新选择
	
	# 向下选择
	elif Input.is_action_just_pressed("p1_down") || Input.is_action_just_pressed("p2_down"):
		if index < posY.size() - 1:
			index += 1 # 增加索引
			setMode(index) # 更新选择
	
	# 确认选择
	if Input.is_action_just_pressed("select"):
		if player.is_playing():
			player.play("RESET") # 重置玩家动画
			return
		startGame() # 开始游戏

# 按钮点击处理
func _on_button_pressed() -> void:
	tipDialog.hide() # 隐藏提示对话框

# 联机对话框确认按钮处理 作为主机
func _on_online_connect_pressed():
	startOnlineHost()
	

#加入房间
func _on_btn_join_pressed() -> void:
	joinOnlineRoom()

# 联机对话框取消按钮处理
func _on_online_cancel_pressed():
	onlineDialog.hide() # 隐藏联机对话框


func _on_online_dialog_close_requested() -> void:
	onlineDialog.hide()
