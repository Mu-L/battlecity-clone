extends AnimatedSprite2D

# 是否大爆炸
var big=false
# 是否播放音效
var playSound=false
# 爆炸所有者类型（玩家/敌人）
var own=Game.objType.ENEMY 
# 玩家爆炸音效
@onready var playerSound=$player
# 敌人爆炸音效
@onready var enemySound=$enemy

# 初始化函数
func _ready():
	if big:
		play("big")  # 播放大爆炸动画
	else:
		play("default")  # 播放普通爆炸动画
		
	if playSound:
		if own==Game.objType.ENEMY:
			enemySound.play()  # 播放敌人爆炸音效
		elif own==Game.objType.PLAYER:
			playerSound.play()  # 播放玩家爆炸音效
	await self.animation_finished  # 等待动画播放完毕
	queue_free()  # 释放爆炸对象
