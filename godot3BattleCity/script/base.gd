extends Area2D

# 是否被摧毁
var destroy=false
# 对象类型标识
var objType=Game.objType.BASE
# 动画节点引用（Godot 3 使用 onready）
onready var ani=$ani
# 碰撞形状节点
onready var shape=$shape
# 爆炸音效节点
onready var explosion=$explosion
# 爆炸效果预制体
var explode=preload("res://scene/explode.tscn")

# 初始化函数
func _ready():
	pass

# 添加爆炸效果
func addexplode():
	var temp = explode.instance()  # Godot 3 使用 .instance()
	temp.position=position  # 设置爆炸位置
	temp.big=true  # 设置为大爆炸
	Game.map.addOther(temp)  # 添加到地图

# 碰撞检测处理（Godot 3 使用 _on_base_area_entered）
func _on_base_area_entered(area):
	if area.get('objType')==Game.objType.BULLET:  # 检测是否为子弹
		if !destroy:  # 如果基地还未被摧毁
			set_deferred('monitorable',false)  # 禁用碰撞检测
			set_deferred('monitoring',false)  # 禁用碰撞检测
			destroy=true  # 设置摧毁标志
			ani.play("destroy")  # 播放基地摧毁动画
			Game.emit_signal("baseDestroyed")  # 发送基地被摧毁信号
			explosion.play()  # 播放爆炸音效
			addexplode()  # 添加爆炸效果