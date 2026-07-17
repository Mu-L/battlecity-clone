extends Node2D

# 计时器节点
@onready var timer=$Timer
# 分数标签节点
@onready var label=$Label

# 设置分数值
func setScore(s:int):
	label.text="%d"%s  # 设置标签显示内容

# 计时器超时处理
func _on_timer_timeout():
	queue_free()  # 释放自身
