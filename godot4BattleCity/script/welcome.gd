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
	
	# 返回主菜单时清理联机状态
	NetworkManager.close()
	Game.mode = Game.gameMode.SINGLE
	Game.scene_data = {}
	# 连接联机信号
	NetworkManager.player_joined.connect(_on_player_joined)
	NetworkManager.joined_server.connect(_on_joined_server)
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
	elif selectedMode == mode.ONLINE_HOST or selectedMode == mode.ONLINE_JOIN:
		openOnlineDialog() # 弹出联机对话框
	elif selectedMode == mode.MAPVIEW:
		Game.changeScene("res://scene/map_view.tscn") # 进入地图查看场景
	elif selectedMode == mode.SETTING:
		Game.changeScene("res://scene/setting.tscn") # 进入设置场景
	elif selectedMode == mode.CONFIGMAP:
		Game.changeScene("res://scene/editmap.tscn") # 进入地图编辑器场景

# 打开联机对话框（普通 Window，点击外部或按 ESC 都不会自动关闭）
func openOnlineDialog():
	onlineDialog.position = Vector2i(106, 114) # 在 512x448 视口中居中
	onlineDialog.show()

# 创建联机房间（作为主机）
func startOnlineHost():
	if Game.mapList.size() == 0:
		tipDialog.popup_centered()
		return
	statusLabel.text = "正在创建房间..."
	if not NetworkManager.host():
		statusLabel.text = "创建房间失败"
		return
	Game.mode = Game.gameMode.ONLINE
	Game.resetData()
	btnHost.disabled = true
	btnJoin.disabled = true
	statusLabel.text = "房间创建成功，等待玩家加入..."

# 加入联机房间（作为客户端）
func joinOnlineRoom():
	var ip: String = ipInput.text.strip_edges()
	var port = int(portInput.text) if portInput.text else NetworkManager.DEFAULT_PORT
	if ip.is_empty():
		statusLabel.text = "请输入服务器IP"
		return
	if not NetworkManager.join(ip, port):
		statusLabel.text = "连接失败"
		return
	Game.mode = Game.gameMode.ONLINE
	Game.resetData()
	btnHost.disabled = true
	btnJoin.disabled = true
	statusLabel.text = "正在连接到 " + ip + ":" + str(port) + "..."

# 主机：有玩家加入，开始游戏
func _on_player_joined(_peer_id: int) -> void:
	if not NetworkManager.is_server():
		return
	statusLabel.text = "玩家已加入，开始游戏！"
	await get_tree().create_timer(0.3).timeout
	NetworkManager.change_scene("res://scene/splash.tscn")

# 客户端：连接主机成功，等待主机开始游戏
func _on_joined_server() -> void:
	statusLabel.text = "已连接，等待主机开始游戏..."

# 连接失败处理
func _on_connection_failed(reason):
	statusLabel.text = "连接失败: " + reason
	btnHost.disabled = false
	btnJoin.disabled = false
	Game.mode = Game.gameMode.SINGLE

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
	NetworkManager.close()
	Game.mode = Game.gameMode.SINGLE
	btnHost.disabled = false
	btnJoin.disabled = false
	onlineDialog.hide() # 隐藏联机对话框


func _on_online_dialog_close_requested() -> void:
	_on_online_cancel_pressed()
