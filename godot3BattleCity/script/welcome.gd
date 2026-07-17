extends Node2D

# 坦克选择位置列表（Y坐标）
var posY=[240,265,295,320,350]
# 当前选择索引
var index=0

# 菜单模式枚举
enum mode{
	P1,          # 单人模式
	P2,          # 双人模式
	CONFIGMAP,   # 地图编辑器
	SETTING,     # 设置
	MAPVIEW      # 地图查看
}

# 当前选中的模式
var selectedMode=mode.P1
# 上次按键时间（用于判断是否进入演示视频）
var lastInputTime=0

# 节点引用（Godot 3 使用 onready）
onready var tankAni=$main/tankAni  # 坦克动画节点
onready var player=$player  # 玩家动画节点
onready var tipDialog=$PopupPanel  # 提示对话框节点
onready var timer=$Timer  # 计时器节点

# 初始化函数
func _ready():
	VisualServer.set_default_clear_color('#000')  # 设置背景色为黑色（Godot 3 使用 VisualServer）
	player.play("move")  # 播放玩家动画


# 设置当前菜单模式
func setMode(index):
	tankAni.position.y=posY[index]  # 更新坦克选择位置
	if index==0:
		selectedMode=mode.P1  # 单人模式
	elif index==1:
		selectedMode=mode.P2  # 双人模式
	elif index==2:
		selectedMode=mode.CONFIGMAP  # 地图编辑器
	elif index==3:
		selectedMode=mode.SETTING  # 设置
	elif index==4:
		selectedMode=mode.MAPVIEW  # 地图查看			

# 开始游戏或进入对应模式
func startGame():
	if selectedMode in [mode.P1,mode.P2]:  # 游戏模式
		if Game.mapList.size()==0:  # 地图为空时提示
			tipDialog.popup_centered()  # 弹出提示对话框
			return
		
		var temp=load("res://scene/splash.tscn")  # 加载开场场景
		Game.resetData()  # 重置游戏数据
		
		if selectedMode==mode.P1:
			Game.mode=Game.gameMode.SINGLE  # 设置为单人模式
		elif selectedMode==mode.P2:
			Game.mode=Game.gameMode.DOUBLE  # 设置为双人模式
		
		var scene=temp.instance()  # Godot 3 使用 .instance()
		scene.selectLevel=true  # 允许选择关卡
		get_tree().root.add_child(scene)  # 添加到根节点
		get_tree().current_scene=scene  # 设置为当前场景
		queue_free()  # 释放当前场景
		
	elif selectedMode==	mode.MAPVIEW:
		Game.changeScene("res://scene/mapView.tscn")  # 进入地图查看场景
	elif selectedMode==mode.SETTING:
		Game.changeScene("res://scene/setting.tscn")  # 进入设置场景
	elif selectedMode==mode.CONFIGMAP:
		Game.changeScene("res://scene/editmap.tscn")  # 进入地图编辑器场景

# 启动计时器（用于演示视频自动播放）
func startTimer():
	if !timer.is_stopped():
		timer.stop()  # 停止现有计时器
	timer.start()  # 启动计时器

# 输入处理
func _input(event):
	# 向上选择
	if Input.is_action_just_pressed("p1_up")||Input.is_action_just_pressed("p2_up"):
		if index>0:
			index-=1  # 减少索引
			setMode(index)  # 更新选择
		lastInputTime=Time.get_ticks_msec()  # 记录上次按键时间
	# 向下选择
	elif Input.is_action_just_pressed("p1_down")||Input.is_action_just_pressed("p2_down"):
		if index<posY.size()-1:
			index+=1  # 增加索引
			setMode(index)  # 更新选择
		lastInputTime=Time.get_ticks_msec()  # 记录上次按键时间		
	# 确认选择
	if Input.is_action_just_pressed("select"):
		if player.is_playing():
			player.play("RESET")  # 重置玩家动画
			startTimer()  # 启动计时器
			return
		startGame()  # 开始游戏
		lastInputTime=Time.get_ticks_msec()  # 记录上次按键时间	


# 按钮点击处理（隐藏提示对话框）
func _on_Button_pressed():
	tipDialog.hide()  # 隐藏提示对话框


# 计时器超时处理（用于演示视频自动播放）
func _on_Timer_timeout():
	if Time.get_ticks_msec()-lastInputTime>5*1000:  # 如果超过5秒没有输入
		Game.changeScene("res://scene/video.tscn")  # 进入演示视频场景
	else:
		startTimer()  # 继续计时