extends Control

# 是否自动隐藏
export var autoHide=true
# 计时器节点（Godot 3 使用 onready）
onready var timer=$Timer

# 初始化函数
func _ready():
	if autoHide:
		timer.start()  # 启动计时器


# 计时器超时处理（Godot 3 使用 _on_Timer_timeout）
func _on_Timer_timeout():
	queue_free()  # 释放自身