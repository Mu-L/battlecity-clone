extends Node2D

# 计时器节点（Godot 3 使用 onready）
onready var timer=$Timer
# 分数标签节点
onready var label=$Label

# 初始化函数
func _ready():
	pass

# 设置分数值
func setScore(s:int):
	label.text="%d"%s  # 设置标签显示内容

# 计时器超时处理（Godot 3 使用 _on_Timer_timeout）
func _on_Timer_timeout():
	queue_free()  # 释放自身