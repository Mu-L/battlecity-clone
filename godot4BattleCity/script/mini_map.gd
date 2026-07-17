extends Node2D

# 单元格大小
const cellSize=16
# 地图缩放比例
@export var mapScale=Vector2(1,1)
# 地图块预制体
var tile=preload("res://scene/tile.tscn")
# 子节点容器
@onready var childNode=$child


# 加载地图
func loadMap(filePath:String):
	# 清除现有地图块
	for i in childNode.get_children():
		childNode.remove_child(i)
	
	var file = FileAccess.open(filePath, FileAccess.READ)  # 打开文件
	if file:
		var json=JSON.new()
		var currentLevel=json.parse_string(file.get_as_text())  # 解析JSON
		file.close()  # 关闭文件
		
		# 加载地图数据
		for i in currentLevel['data']:
			if int(i['type']) in [0,1,2,3,4]:  # 只加载有效的砖块类型
				var temp=tile.instantiate()  # 创建地图块
				temp.position.x=int(i['x'])*cellSize+cellSize/2  # 设置X坐标
				temp.position.y=int(i['y'])*cellSize+cellSize/2  # 设置Y坐标
				temp.type=int(i['type'])  # 设置砖块类型
				childNode.add_child(temp)  # 添加到子节点容器
		
		childNode.scale=mapScale  # 设置缩放比例
