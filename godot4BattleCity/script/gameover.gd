extends Node2D

# 计时器节点
@onready var timer=$Timer
# 音效节点
@onready var sound=$sound


# 初始化函数
func _ready():
	timer.start()  # 启动计时器


# 计时器超时处理
func _on_timer_timeout():
	sound.play()  # 播放游戏结束音效
	await sound.finished  # 等待音效播放完毕
	
	# 等待90帧（约1.5秒）
	for i in range(90):
		await get_tree().physics_frame
	
	Game.changeScene("res://scene/welcome.tscn")  # 返回欢迎界面	
