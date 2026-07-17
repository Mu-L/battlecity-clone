extends Node2D

# 计时器节点（Godot 3 使用 onready）
onready var timer=$Timer
# 音效节点
onready var sound=$sound

# 初始化函数
func _ready():
	timer.start()  # 启动计时器


# 计时器超时处理（Godot 3 使用 _on_Timer_timeout）
func _on_Timer_timeout():
	sound.play()  # 播放游戏结束音效
	yield(sound,"finished")  # 等待音效播放完毕（Godot 3 使用 yield）
	
	# 等待90帧（约1.5秒）
	for i in range(90):
		yield(get_tree(),"physics_frame")
	
	Game.changeScene("res://scene/welcome.tscn")  # 返回欢迎界面