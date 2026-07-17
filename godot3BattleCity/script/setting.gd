extends Control

# 节点引用（Godot 3 使用 onready）
onready var masterSliderNode=$TabContainer/General/MarginContainer3/vbox/master  # 主音量滑块节点
onready var bgSliderNode=$TabContainer/General/MarginContainer3/vbox/bg  # 背景音乐音量滑块节点
onready var sfxSliderNode=$TabContainer/General/MarginContainer3/vbox/sfx  # 音效音量滑块节点
onready var useExtensionMapNode=$TabContainer/General/MarginContainer2/CheckButton  # 使用扩展地图复选框节点

# 初始化函数
func _ready():
	VisualServer.set_default_clear_color('#000')  # 设置背景色为黑色（Godot 3 使用 VisualServer）
	
	# 设置滑块名称
	masterSliderNode.setName('Master')
	bgSliderNode.setName('bg')
	sfxSliderNode.setName('sfx')

	# 设置滑块初始值
	masterSliderNode.slider.value=Game.config.Volume.Master*100
	bgSliderNode.slider.value=Game.config.Volume.Bg*100
	sfxSliderNode.slider.value=Game.config.Volume.Sfx*100

	# 连接滑块值变化信号（Godot 3 使用 .connect()）
	masterSliderNode.slider.connect("value_changed",self,"_on_master_value_changed")
	bgSliderNode.slider.connect("value_changed",self,"_on_bg_value_changed")
	sfxSliderNode.slider.connect("value_changed",self,"_on_sfx_value_changed")

	# 设置复选框状态
	useExtensionMapNode.pressed=Game.config.Base.useExtensionMap

# 主音量变化处理
func _on_master_value_changed(value):
	masterSliderNode.setVolume(value)  # 设置音量
	masterSliderNode.sound.play()  # 播放测试音效
	Game.config.Volume.Master=value/100  # 更新配置
	Game.saveConfig()  # 保存配置

# 背景音乐音量变化处理
func _on_bg_value_changed(value):	
	bgSliderNode.setVolume(value)  # 设置音量
	bgSliderNode.sound.play()  # 播放测试音效
	Game.config.Volume.Bg=value/100  # 更新配置
	Game.saveConfig()  # 保存配置

# 音效音量变化处理
func _on_sfx_value_changed(value):
	sfxSliderNode.setVolume(value)  # 设置音量
	sfxSliderNode.sound.play()  # 播放测试音效
	Game.config.Volume.Sfx=value/100  # 更新配置
	Game.saveConfig()  # 保存配置


# 使用扩展地图复选框切换处理
func _on_CheckButton_toggled(button_pressed):
	Game.config.Base.useExtensionMap=button_pressed  # 更新配置
	Game.saveConfig()  # 保存配置
	Game.initMap()  # 重新初始化地图


# 返回按钮点击处理
func _on_TextureButton_pressed():
	Game.changeScene("res://scene/welcome.tscn")  # 返回欢迎界面