extends Control

# 是否游戏结束
export var isGameOver=false

# 节点引用（Godot 3 使用 onready）
onready var levelNode=$HBoxContainer2/level  # 关卡标签节点
onready var highScoreNode=$HBoxContainer/highScore  # 最高分标签节点
onready var p1ScoreNode=$VBoxContainer2/p1Score  # 玩家1分数标签节点
onready var p2ScoreNode=$VBoxContainer3/p2Score  # 玩家2分数标签节点
onready var totalResultNode=$totalResultNode  # 总分结果节点
onready var p1TotalNode=$totalResultNode/p1Total  # 玩家1总分节点
onready var p2TotalNode=$totalResultNode/p2Total  # 玩家2总分节点
onready var p1ScoreListNode=$p1ScoreList  # 玩家1分数列表节点
onready var p1TypeAScoreNode=$p1ScoreList/typeA/typeAScore  # 玩家1 A型敌人分数节点
onready var p1TypeANumNode=$p1ScoreList/typeA/HBoxContainer/typeANum  # 玩家1 A型敌人数量节点
onready var p1TypeBScoreNode=$p1ScoreList/typeB/typeBScore  # 玩家1 B型敌人分数节点
onready var p1TypeBNumNode=$p1ScoreList/typeB/HBoxContainer/typeBNum  # 玩家1 B型敌人数量节点
onready var p1TypeCScoreNode=$p1ScoreList/typeC/typeCScore  # 玩家1 C型敌人分数节点
onready var p1TypeCNumNode=$p1ScoreList/typeC/HBoxContainer/typeCNum  # 玩家1 C型敌人数量节点
onready var p1TypeDScoreNode=$p1ScoreList/typeD/typeDScore  # 玩家1 D型敌人分数节点
onready var p1TypeDNumNode=$p1ScoreList/typeD/HBoxContainer/typeDNum  # 玩家1 D型敌人数量节点
onready var p2ScoreListNode=$p2ScoreList  # 玩家2分数列表节点
onready var p2TypeANumNode=$p2ScoreList/typeA/HBoxContainer/typeANum  # 玩家2 A型敌人数量节点
onready var p2TypeAScoreNode=$p2ScoreList/typeA/typeAScore  # 玩家2 A型敌人分数节点
onready var p2TypeBNumNode=$p2ScoreList/typeB/HBoxContainer/typeBNum  # 玩家2 B型敌人数量节点
onready var p2TypeBScoreNode=$p2ScoreList/typeB/typeBScore  # 玩家2 B型敌人分数节点
onready var p2TypeCNumNode=$p2ScoreList/typeC/HBoxContainer/typeCNum  # 玩家2 C型敌人数量节点
onready var p2TypeCScoreNode=$p2ScoreList/typeC/typeCScore  # 玩家2 C型敌人分数节点
onready var p2TypeDNumNode=$p2ScoreList/typeD/HBoxContainer/typeDNum  # 玩家2 D型敌人数量节点
onready var p2TypeDScoreNode=$p2ScoreList/typeD/typeDScore  # 玩家2 D型敌人分数节点
onready var rewardNode=$reward  # 奖励节点

# 计时器节点
onready var timer=$Timer

# 玩家1分数
var p1Score=0
# 玩家2分数
var p2Score=0
# 敌人类型列表
var scoreType=[Game.enemyType.TYPEA,Game.enemyType.TYPEB,
				Game.enemyType.TYPEC,Game.enemyType.TYPED]
# 当前计数索引
var countIndex=0

# 初始化函数
func _ready():
	VisualServer.set_default_clear_color('#000')  # 设置背景色为黑色（Godot 3 使用 VisualServer）
	p1Score=Game.p1Data['score']  # 获取玩家1分数
	p2Score=Game.p2Data['score']  # 获取玩家2分数
	p1ScoreNode.text="%d"%p1Score  # 显示玩家1分数
	p2ScoreNode.text="%d"%p2Score  # 显示玩家2分数
	levelNode.text='%d'%(Game.gameLevel+1)  # 显示关卡数
	
	# 设置最高分（取两个玩家中较低的分数作为最高分）
	if p1Score>=p2Score:
		highScoreNode.text="%d"%p2Score
	else:
		highScoreNode.text="%d"%p2Score
	
	# 根据游戏模式显示不同界面
	if Game.mode==Game.gameMode.SINGLE:
		pass  # 单人模式不需要额外处理
	elif Game.mode==Game.gameMode.DOUBLE:
		p2ScoreListNode.visible=true  # 双人模式显示玩家2分数列表


# 显示分数动画
func showScore():
	# 从坦克A开始计算
	if countIndex==0:
		var tempP1Num=0  # 玩家1当前计数
		var tempP2Num=0  # 玩家2当前计数
		setNumLable(0,Game.enemyType.TYPEA,tempP1Num)  # 设置玩家1 A型敌人计数
		if Game.mode==Game.gameMode.DOUBLE:
			setNumLable(1,Game.enemyType.TYPEA,tempP2Num)  # 设置玩家2 A型敌人计数
		
		# 逐步显示计数动画
		while tempP1Num<Game.p1Score['typeA']||tempP2Num<Game.p2Score['typeA']:
			if tempP1Num<Game.p1Score['typeA']:
				tempP1Num+=1
				setNumLable(0,Game.enemyType.TYPEA,tempP1Num)  # 更新玩家1计数
			if tempP2Num<Game.p2Score['typeA']:
				tempP2Num+=1
				setNumLable(1,Game.enemyType.TYPEA,tempP2Num)  # 更新玩家2计数
			SoundsUtil.playPoint()  # 播放分数音效	
			for i in range(15):
				yield(get_tree(),"physics_frame")  # 等待15帧（约0.25秒）
		
		if tempP1Num==0 && tempP2Num==0:
			for i in range(20):
				yield(get_tree(),"physics_frame")  # 如果没有击杀，等待20帧（约0.33秒）

		countIndex+=1  # 增加计数索引
		showScore()  # 递归显示下一个类型
	
	elif countIndex==1:
		# 显示B型敌人分数
		var tempP1Num=0
		var tempP2Num=0
		setNumLable(0,Game.enemyType.TYPEB,tempP1Num)
		if Game.mode==Game.gameMode.DOUBLE:
			setNumLable(1,Game.enemyType.TYPEB,tempP2Num)
		while tempP1Num<Game.p1Score['typeB']||tempP2Num<Game.p2Score['typeB']:
			if tempP1Num<Game.p1Score['typeB']:
				tempP1Num+=1
				setNumLable(0,Game.enemyType.TYPEB,tempP1Num)
			if tempP2Num<Game.p2Score['typeB']:
				tempP2Num+=1
				setNumLable(1,Game.enemyType.TYPEB,tempP2Num)
			SoundsUtil.playPoint()		
			for i in range(15):
				yield(get_tree(),"physics_frame")
		if tempP1Num==0 && tempP2Num==0:
			for i in range(20):
				yield(get_tree(),"physics_frame")
		countIndex+=1
		showScore()
	
	elif countIndex==2:
		# 显示C型敌人分数
		var tempP1Num=0
		var tempP2Num=0
		setNumLable(0,Game.enemyType.TYPEC,tempP1Num)
		if Game.mode==Game.gameMode.DOUBLE:
			setNumLable(1,Game.enemyType.TYPEC,tempP2Num)
		while tempP1Num<Game.p1Score['typeC']||tempP2Num<Game.p2Score['typeC']:
			if tempP1Num<Game.p1Score['typeC']:
				tempP1Num+=1
				setNumLable(0,Game.enemyType.TYPEC,tempP1Num)
			if tempP2Num<Game.p2Score['typeC']:
				tempP2Num+=1
				setNumLable(1,Game.enemyType.TYPEC,tempP2Num)
			SoundsUtil.playPoint()		
			for i in range(15):
				yield(get_tree(),"physics_frame")	
		if tempP1Num==0 && tempP2Num==0:
			for i in range(20):
				yield(get_tree(),"physics_frame")
		countIndex+=1
		showScore()			
	elif countIndex==3:		
		# 显示D型敌人分数
		var tempP1Num=0
		var tempP2Num=0
		setNumLable(0,Game.enemyType.TYPED,tempP1Num)
		if Game.mode==Game.gameMode.DOUBLE:
			setNumLable(1,Game.enemyType.TYPED,tempP2Num)
		while tempP1Num<Game.p1Score['typeD']||tempP2Num<Game.p2Score['typeD']:
			if tempP1Num<Game.p1Score['typeD']:
				tempP1Num+=1
				setNumLable(0,Game.enemyType.TYPED,tempP1Num)
			if tempP2Num<Game.p2Score['typeD']:
				tempP2Num+=1
				setNumLable(1,Game.enemyType.TYPED,tempP2Num)
			SoundsUtil.playPoint()		
			for i in range(15):
				yield(get_tree(),"physics_frame")	
		if tempP1Num==0 && tempP2Num==0:
			for i in range(20):
				yield(get_tree(),"physics_frame")
		countIndex+=1
		showScore()	
	else:
		# 显示总分
		var p1Num=Game.p1Score['typeA']+\
				Game.p1Score['typeB']+Game.p1Score['typeC']+\
				Game.p1Score['typeD']
		p1TotalNode.visible=true  # 显示玩家1总分
		p1TotalNode.text="%d"%p1Num  # 设置玩家1总分
		
		if Game.mode==Game.gameMode.DOUBLE:	
			var p2Num=Game.p2Score['typeA']+\
				Game.p2Score['typeB']+Game.p2Score['typeC']+\
				Game.p2Score['typeD']
			p2TotalNode.text="%d"%p2Num  # 设置玩家2总分
			p2TotalNode.visible=true  # 显示玩家2总分
			
			# 双人模式下判断胜负
			if p1Num>p2Num:
				SoundsUtil.playAward()  # 播放奖励音效
				Game.p1Data['score']+=1000  # 玩家1获得1000分奖励
				rewardNode.visible=true  # 显示奖励标签
				rewardNode.set_position(Vector2(8,400))  # 设置奖励标签位置
			elif p1Num<p2Num&&p2Num!=0:
				SoundsUtil.playAward()  # 播放奖励音效
				Game.p2Data['score']+=1000  # 玩家2获得1000分奖励	
				rewardNode.visible=true  # 显示奖励标签
				rewardNode.set_position(Vector2(392,400))  # 设置奖励标签位置
		for i in range(60):
			yield(get_tree(),"physics_frame")  # 等待60帧（约1秒）		
		timer.start()  # 启动计时器
		
# 设置分数标签
func setNumLable(id,type,num):
	if id==0:  # 玩家1
		if type==Game.enemyType.TYPEA:
			p1TypeAScoreNode.text='%d'%(num*100)  # A型敌人分数（100分/个）
			p1TypeANumNode.text='%d'%num  # A型敌人数量
		elif type==Game.enemyType.TYPEB:
			p1TypeBScoreNode.text='%d'%(num*200)  # B型敌人分数（200分/个）
			p1TypeBNumNode.text='%d'%num  # B型敌人数量
		elif type==Game.enemyType.TYPEC:
			p1TypeCScoreNode.text='%d'%(num*300)  # C型敌人分数（300分/个）
			p1TypeCNumNode.text='%d'%num  # C型敌人数量
		elif type==Game.enemyType.TYPED:
			p1TypeDScoreNode.text='%d'%(num*400)  # D型敌人分数（400分/个）
			p1TypeDNumNode.text='%d'%num  # D型敌人数量
	elif  id==1:  # 玩家2					
		if type==Game.enemyType.TYPEA:
			p2TypeAScoreNode.text='%d'%(num*100)  # A型敌人分数（100分/个）
			p2TypeANumNode.text='%d'%num  # A型敌人数量
		elif type==Game.enemyType.TYPEB:
			p2TypeBScoreNode.text='%d'%(num*200)  # B型敌人分数（200分/个）
			p2TypeBNumNode.text='%d'%num  # B型敌人数量
		elif type==Game.enemyType.TYPEC:
			p2TypeCScoreNode.text='%d'%(num*300)  # C型敌人分数（300分/个）
			p2TypeCNumNode.text='%d'%num  # C型敌人数量
		elif type==Game.enemyType.TYPED:
			p2TypeDScoreNode.text='%d'%(num*400)  # D型敌人分数（400分/个）
			p2TypeDNumNode.text='%d'%num  # D型敌人数量				

# 进入下一关或游戏结束
func nextLevel():
	if isGameOver:
		gameOver()  # 游戏结束
		return
	
	# 判断是否是最后一关
	if Game.gameLevel>=Game.mapList.size()-1:
		var temp=load("res://scene/info.tscn")  # 加载信息场景
		var scene=temp.instance()  # Godot 3 使用 .instance()
		scene.disableInput=true  # 禁用输入
		get_tree().root.add_child(scene)  # 添加到根节点
		get_tree().current_scene=scene  # 设置为当前场景
		queue_free()  # 释放当前场景
	else:
		Game.gameLevel+=1  # 增加关卡数
		var temp=load("res://scene/splash.tscn")  # 加载开场场景
		get_tree().change_scene_to(temp)  # 切换到开场场景（Godot 3 使用 change_scene_to）
		
# 游戏结束处理
func gameOver():
	var temp=load("res://scene/gameover.tscn")  # 加载游戏结束场景
	get_tree().change_scene_to(temp)  # 切换到游戏结束场景	

# 计时器超时处理（Godot 3 使用 _on_Timer_timeout）
func _on_Timer_timeout():
	nextLevel()  # 进入下一关

# 开始计时器超时处理（Godot 3 使用 _on_startTimer_timeout）
func _on_startTimer_timeout():
	showScore()  # 开始显示分数动画