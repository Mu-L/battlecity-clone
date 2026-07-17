extends Node2D

# 地图数量标签节点
@onready var mapCountNode=$Control/hbox/mapCount
# 页码节点
@onready var pageNode=$Control/hbox/page
# 6个小地图预览节点
@onready var miniMap1=$miniMap
@onready var miniMap2=$miniMap2
@onready var miniMap3=$miniMap3
@onready var miniMap4=$miniMap4
@onready var miniMap5=$miniMap5
@onready var miniMap6=$miniMap6
# 小地图名称标签节点
@onready var miniMap1Name=$miniMap/Label
@onready var miniMap2Name=$miniMap2/Label
@onready var miniMap3Name=$miniMap3/Label
@onready var miniMap4Name=$miniMap4/Label
@onready var miniMap5Name=$miniMap5/Label
@onready var miniMap6Name=$miniMap6/Label

# 内置地图路径
const mapDir="res://level"
# 当前页码
var page=0

# 初始化函数
func _ready():
	RenderingServer.set_default_clear_color('#646464')  # 设置背景色
	page=ceil(Game.mapList.size()/6.0)  # 计算总页数
	
	# 添加页码选项
	for i in range(1,page+1):
		pageNode.add_item(str(i))
	
	mapCountNode.text='mapcount:%d'%Game.mapList.size()  # 显示地图总数
	showMap(0)  # 显示第一页地图

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

# 返回按钮点击处理
func _on_button_pressed():
	Game.changeScene("res://scene/welcome.tscn")  # 返回欢迎界面
