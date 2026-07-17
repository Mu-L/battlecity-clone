extends VBoxContainer

# 音频总线名称
export var busName='Master'
# 音量值
export var volume:float=0.0 

# 节点引用（Godot 3 使用 onready）
onready var slider=$HSlider  # 滑块节点
onready var label=$Label  # 标签节点
onready var sound=$AudioStreamPlayer  # 音效播放器节点


# 设置音频总线名称
func setName(busName):
	self.busName=busName  # 更新总线名称
	label.text=str(busName)  # 更新标签显示
	sound.bus=self.busName  # 设置音效播放器的总线


# 设置音量
func setVolume(volume:float):
	self.volume=volume  # 更新音量值
	# 将线性音量转换为分贝并设置到音频总线（Godot 3 使用 linear2db）
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(busName), linear2db(self.volume/100))