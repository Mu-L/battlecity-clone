extends Control

# 是否自动隐藏
@export var autoHide=true
# 计时器节点
@onready var timer=$Timer

# 初始化函数
func _ready():
	if autoHide:
		timer.start()  # 启动计时器


# 计时器超时处理
func _on_timer_timeout():
	queue_free()  # 释放自身
