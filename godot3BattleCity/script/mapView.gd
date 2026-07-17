extends Node2D

# 节点引用（Godot 3 使用 onready）
onready var mapCountNode=$Control/hbox/mapCount  # 地图数量标签节点
onready var pageNode=$Control/hbox/page  # 页码节点
onready var miniMap1=$miniMap  # 小地图1节点
onready var miniMap2=$miniMap2  # 小地图2节点
onready var miniMap3=$miniMap3  # 小地图3节点
onready var miniMap4=$miniMap4  # 小地图4节点
onready var miniMap5=$miniMap5  # 小地图5节点
onready var miniMap6=$miniMap6  # 小地图6节点
onready var miniMap1Name=$miniMap/Label  # 小地图1名称标签节点
onready var miniMap2Name=$miniMap2/Label  # 小地图2名称标签节点
onready var miniMap3Name=$miniMap3/Label  # 小地图3名称标签节点
onready var miniMap4Name=$miniMap4/Label  # 小地图4名称标签节点
onready var miniMap5Name=$miniMap5/Label  # 小地图5名称标签节点
onready var miniMap6Name=$miniMap6/Label  # 小地图6名称标签节点
onready var btnClose=$Control/hbox/Button  # 关闭按钮

# 内置地图路径
const mapDir="res://level"
# 当前页码
var page=0


# 初始化函数
func _ready():
	VisualServer.set_default_clear_color('#646464')  # 设置背景色（Godot 3 使用 VisualServer）
	page=ceil(Game.mapList.size()/6.0)  # 计算总页数
	
	# 添加页码选项
	for i in range(1,page+1):
		pageNode.add_item(str(i))
	
	mapCountNode.text='mapcount:%d'%Game.mapList.size()  # 显示地图总数
	showMap(0)  # 显示第一页地图
	btnClose.grab_focus()  # 设置关闭按钮为焦点

# 设置显示的地图	
func showMap(page):
	# 隐藏所有小地图
	miniMap1.visible=false
	miniMap2.visible=false
	miniMap3.visible=false
	miniMap4.visible=false
	miniMap5.visible=false
	miniMap6.visible=false
	
	var start=page*6  # 计算起始索引
	
	# 显示当前页的地图
	for i in range(6):
		if start+i<Game.mapList.size():  # 检查是否还有地图
			if i==0:
				miniMap1.visible=true  # 显示小地图1
				miniMap1.loadMap(mapDir+"/"+Game.mapList[start+i])  # 加载地图
				miniMap1Name.text=str(Game.mapList[start+i])  # 设置名称
			elif i==1:
				miniMap2.visible=true  # 显示小地图2
				miniMap2.loadMap(mapDir+"/"+Game.mapList[start+i])  # 加载地图
				miniMap2Name.text=str(Game.mapList[start+i])  # 设置名称
			elif i==2:
				miniMap3.visible=true  # 显示小地图3
				miniMap3.loadMap(mapDir+"/"+Game.mapList[start+i])  # 加载地图
				miniMap3Name.text=str(Game.mapList[start+i])  # 设置名称
			elif i==3:
				miniMap4.visible=true  # 显示小地图4
				miniMap4.loadMap(mapDir+"/"+Game.mapList[start+i])  # 加载地图
				miniMap4Name.text=str(Game.mapList[start+i])  # 设置名称
			elif i==4:
				miniMap5.visible=true  # 显示小地图5
				miniMap5.loadMap(mapDir+"/"+Game.mapList[start+i])  # 加载地图
				miniMap5Name.text=str(Game.mapList[start+i])  # 设置名称
			elif i==5:
				miniMap6.visible=true  # 显示小地图6
				miniMap6.loadMap(mapDir+"/"+Game.mapList[start+i])  # 加载地图
				miniMap6Name.text=str(Game.mapList[start+i])  # 设置名称


# 页码选择处理
func _on_page_item_selected(index):
	showMap(index)  # 显示选中页的地图


# 关闭按钮点击处理
func _on_Button_pressed():
	Game.changeScene("res://scene/welcome.tscn")  # 返回欢迎界面