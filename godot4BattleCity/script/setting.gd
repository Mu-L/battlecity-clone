extends Control

# 主音量滑块节点
@onready var masterSliderNode=$TabContainer/General/MarginContainer3/vbox/master
# 背景音乐音量滑块节点
@onready var bgSliderNode=$TabContainer/General/MarginContainer3/vbox/vg
# 音效音量滑块节点
@onready var sfxSliderNode=$TabContainer/General/MarginContainer3/vbox/sfx
# 使用扩展地图复选框节点
@onready var useExtensionMapNode=$TabContainer/General/MarginContainer/CheckButton

# 初始化函数
func _ready() -> void:
	RenderingServer.set_default_clear_color('#000')  # 设置背景色为黑色
	
	# 设置滑块名称
	masterSliderNode.setName('Master')
	bgSliderNode.setName('Bg')
	sfxSliderNode.setName('Sfx')

	# 设置滑块初始值
	masterSliderNode.slider.value=Game.config.Volume.Master*100
	bgSliderNode.slider.value=Game.config.Volume.Bg*100
	sfxSliderNode.slider.value=Game.config.Volume.Sfx*100
	
	# 连接滑块值变化信号
	masterSliderNode.slider.value_changed.connect(_on_master_value_changed)
	bgSliderNode.slider.value_changed.connect(_on_bg_value_changed)
	sfxSliderNode.slider.value_changed.connect(_on_sfx_value_changed)
	
	# 设置复选框状态
	useExtensionMapNode.button_pressed=Game.config.Base.useExtensionMap

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
func _on_check_button_toggled(toggled_on: bool) -> void:
	Game.config.Base.useExtensionMap=toggled_on  # 更新配置
	Game.saveConfig()  # 保存配置
	Game.initMap()  # 重新初始化地图
