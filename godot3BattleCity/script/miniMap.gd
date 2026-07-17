extends Node2D
# 这个用来显示地图内容

# 单元格大小
const cellSize=16	#每个格子的大小是16px
# 地图缩放比例
export var mapScale=Vector2(1,1)
# 地图块预制体
var tile=preload("res://scene/tile.tscn")
# 子节点容器（Godot 3 使用 onready）
onready var childNode=$child


# 加载地图
func loadMap(filePath:String):
	# 清除现有地图块
	for i in childNode.get_children():
		childNode.remove_child(i)
	
	var file = File.new()  # Godot 3 使用 File.new()
	if file.file_exists(filePath):
		file.open(filePath, File.READ)  # 打开文件
		var currentLevel=parse_json(file.get_as_text())  # 解析JSON（Godot 3 使用 parse_json）
		file.close()  # 关闭文件
		
		# 加载地图数据
		for i in currentLevel['data']:
			if i['type'] in [0,1,2,3,4]:  # 只加载有效的砖块类型
				var temp=tile.instance()  # 创建地图块（Godot 3 使用 .instance()）
				temp.position.x=i['x']*cellSize+cellSize/2  # 设置X坐标
				temp.position.y=i['y']*cellSize+cellSize/2  # 设置Y坐标
				temp.type=i['type']  # 设置砖块类型
				childNode.add_child(temp)  # 添加到子节点容器
	else:
		print('文件不存在')  # 文件不存在提示			