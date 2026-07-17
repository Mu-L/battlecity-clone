extends VBoxContainer

# 是否禁用输入
export var disableInput=false
# 标签节点（Godot 3 使用 onready）
onready var label=$ScrollContainer/VBoxContainer/Label
# 内容节点
onready var content=$ScrollContainer/VBoxContainer/RichTextLabel

# 初始化函数
func _ready():
	if disableInput:
		label.visible=true  # 显示标签
		set_physics_process(false)  # 禁用物理处理
	else:
		label.visible=true  # 显示标签

# 输入处理
func _input(event):
	if Input.is_action_pressed("select"):
		Game.changeScene("res://scene/welcome.tscn")  # 返回欢迎界面