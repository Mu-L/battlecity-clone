extends Node2D

# 是否允许选择关卡
@export var selectLevel=false
# 下一个场景
@export var nextScene:PackedScene

# 关卡标签节点
@onready var level=$Label
# 玩家动画节点
@onready var player=$player

# 初始化函数
func _ready():
	set_process_input(false)  # 禁用输入处理
	player.play("in")  # 播放进入动画
	await player.animation_finished  # 等待动画播放完毕
	
	level.text="stage %d"%(Game.gameLevel+1)  # 显示关卡数
	
	if selectLevel:
		set_process_input(true)  # 启用输入处理（允许选择关卡）
	else:
		# 自动模式：等待1.5秒后进入游戏
		await get_tree().create_timer(1.5).timeout
		startGame()

#开始游戏
func startGame():
	# 联机时由主机决定进入游戏，客户端等待主机的场景切换指令
	if Game.isClient():
		return
	if Game.isOnline():
		NetworkManager.change_scene(nextScene.resource_path)
		return
	var temp=nextScene.instantiate()  # 实例化下一个场景
	get_tree().root.add_child(temp)  # 添加到根节点
	player.play("out")  # 播放退出动画
	SoundsUtil.playMusic()  # 播放背景音乐
	set_process_input(false)  # 禁用输入处理
	await player.animation_finished  # 等待动画播放完毕
	set_physics_process(true)  # 启用物理处理
	get_tree().current_scene=temp  # 设置为当前场景
	queue_free()  # 释放当前场景

func manuallySelectLevel(flag):
	if flag>0:
		if Game.gameLevel<Game.mapList.size()-1:
			Game.gameLevel+=1  # 增加关卡数
			level.text="stage %d"%(Game.gameLevel+1)  # 更新关卡显示
	else:
		if Game.gameLevel>0:
			Game.gameLevel-=1  # 减少关卡数
			level.text="stage %d"%(Game.gameLevel+1)  # 更新关卡显示	

# 输入处理
func _input(_event):
	if Game.isClient():
		return # 联机时关卡选择由主机操作
	
	# 确认选择关卡
	if Input.is_action_pressed("select"):
		startGame()
	
	# 向上选择关卡
	if Input.is_action_pressed("p1_up"):
		manuallySelectLevel(1)
	
	# 向下选择关卡
	if Input.is_action_pressed("p1_down"):
		manuallySelectLevel(-1)
