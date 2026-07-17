extends Node2D

# 地图块预制体
var tile=preload("res://scene/tile.tscn")

# 偏移量
var offset=Vector2(32,16)
# 单元格大小
var cellSize=16	#每个格子的大小是16px
# 地图区域
var mapRect  
# 是否按下鼠标按键
var isPress=false

# 物品类型定义（用于地图编辑器）
var itemType={'del':[],  # 删除
			'typeA':[{'x':0,'y':0,'type':Game.brickType.WALL}],  # 墙壁（单格）
			'typeB':[{'x':0,'y':0,'type':Game.brickType.STONE}],  # 石头（单格）
			'typeC':[{'x':0,'y':0,'type':Game.brickType.WATER}],  # 水（单格）
			'typeD':[{'x':0,'y':0,'type':Game.brickType.BUSH}],  # 草丛（单格）
			'typeE':[{'x':0,'y':0,'type':Game.brickType.ICE}],  # 冰（单格）
			'typeF':[{'x':0,'y':0,'type':Game.brickType.WALL},{'x':1,'y':0,'type':Game.brickType.WALL},
			{'x':0,'y':1,'type':Game.brickType.WALL},{'x':1,'y':1,'type':Game.brickType.WALL}],  # 墙壁（2x2）
			'typeG':[{'x':0,'y':0,'type':Game.brickType.STONE},{'x':1,'y':0,'type':Game.brickType.STONE},
			{'x':0,'y':1,'type':Game.brickType.STONE},{'x':1,'y':1,'type':Game.brickType.STONE}],  # 石头（2x2）
			'typeH':[{'x':0,'y':0,'type':Game.brickType.WATER},{'x':0,'y':1,'type':Game.brickType.WATER},
			{'x':1,'y':0,'type':Game.brickType.WATER},{'x':1,'y':1,'type':Game.brickType.WATER}],  # 水（2x2）
			'typeI':[{'x':0,'y':0,'type':Game.brickType.BUSH},{'x':0,'y':1,'type':Game.brickType.BUSH},
			{'x':1,'y':0,'type':Game.brickType.BUSH},{'x':1,'y':1,'type':Game.brickType.BUSH}],  # 草丛（2x2）
			'typeJ':[{'x':0,'y':0,'type':Game.brickType.ICE},{'x':0,'y':1,'type':Game.brickType.ICE},
			{'x':1,'y':0,'type':Game.brickType.ICE},{'x':1,'y':1,'type':Game.brickType.ICE}],  # 冰（2x2）
			}

# 物品元数据列表
var itemMetadata=['del','typeA','typeB','typeC','typeD','typeE','typeF','typeG',
					'typeH','typeI','typeJ']

# 物品图标路径列表
var itemImg=["res://sprite/del.png","res://sprite/brick.png","res://sprite/stone.png",
			"res://sprite/water1.png","res://sprite/bush.png","res://sprite/ice.png",
			"res://sprite/wall1.png","res://sprite/stone1.png","res://sprite/water4.png",
			"res://sprite/bush1.png","res://sprite/ice1.png"]

# 基地旁的方块位置
var baseBrickPos=[Vector2(11,25),Vector2(11,24),Vector2(11,23),
			Vector2(12,23),Vector2(13,23),Vector2(14,23),
			Vector2(14,25),Vector2(14,24)]

# 当前选中的物品类型
var currentItem=''

# 节点引用（Godot 3 使用 onready）
onready var childNode=$child  # 子节点容器
onready var itemList=$Control/ItemList  # 物品列表节点
onready var fileDialog=$Control/FileDialog  # 保存文件对话框
onready var loadDialog=$Control/loadDialog  # 加载文件对话框
onready var btnReturn=$Control/vbox/return  # 返回按钮

# 初始化函数
func _ready():
	VisualServer.set_default_clear_color('#000')  # 设置背景色为黑色（Godot 3 使用 VisualServer）
	mapRect =Rect2(offset,Vector2(cellSize*26,cellSize*26))  # 设置地图区域
	addBaseBrick()  # 添加基地周边的方块
	
	# 添加物品图标到列表
	for i in itemImg:
		var temp=load(i)  # 加载图标
		itemList.add_icon_item(temp)  # 添加到列表
	
	# 设置物品元数据
	for i in range(itemMetadata.size()):
		itemList.set_item_metadata(i,itemMetadata[i])
	
	currentItem='del'  # 默认选中删除工具
	btnReturn.grab_focus()  # 设置返回按钮为焦点

# 添加基地周边的方块
func addBaseBrick():
	for i in baseBrickPos:
		var temp=tile.instance()  # 创建地图块（Godot 3 使用 .instance()）
		temp.type=Game.brickType.WALL  # 设置为墙壁类型
		temp.position.x=i['x']*cellSize+cellSize/2+offset.x  # 设置X坐标
		temp.position.y=i['y']*cellSize+cellSize/2+offset.y  # 设置Y坐标
		temp.mapPos=Vector2(i['x'],i['y'])  # 设置地图位置
		childNode.add_child(temp)  # 添加到子节点容器

# 载入地图文件
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
				var temp=tile.instance()  # 创建地图块
				temp.position.x=i['x']*cellSize+cellSize/2+offset.x  # 设置X坐标
				temp.position.y=i['y']*cellSize+cellSize/2+offset.y  # 设置Y坐标
				temp.type=i['type']  # 设置砖块类型
				temp.mapPos=Vector2(i['x'],i['y'])  # 设置地图位置
				childNode.add_child(temp)  # 添加到子节点容器
	else:
		print('文件不存在')  # 文件不存在提示		

# 添加方块	
func addItem(pos):
	pos-=offset  # 计算相对于地图的位置
	var indexX=int(pos.x)/cellSize  # 计算X索引
	var indexY=int(pos.y)/cellSize  # 计算Y索引
	var list=itemType[currentItem]  # 获取当前选中物品的列表
	
	# 删除已有的方块
	for i in list:
		var node=checkItem(i.x+indexX,i.y+indexY)  # 检查是否已存在
		if node:
			node.queue_free()  # 释放已存在的方块
	
	# 添加新方块
	for i in list:
		if i['x']+indexX<0||i['x']+indexX>25:  # 边界检查
			continue
		if i['y']+indexY<0||i['y']+indexY>25:  # 边界检查
			continue
		var temp=tile.instance()  # 创建地图块
		temp.position.x=(i['x']+indexX)*cellSize+cellSize/2+offset.x  # 设置X坐标
		temp.position.y=(i['y']+indexY)*cellSize+cellSize/2+offset.y  # 设置Y坐标
		temp.type=i.type  # 设置砖块类型
		temp.mapPos=Vector2(i['x']+indexX,i['y']+indexY)  # 设置地图位置
		childNode.add_child(temp)  # 添加到子节点容器

# 检查指定位置是否有方块
func checkItem(indexX,indexY):
	var node=null
	for i in childNode.get_children():
		if i.mapPos.x==indexX&&i.mapPos.y==indexY:  # 匹配位置
			node=i  # 找到方块
			break
	return node	

# 删除方块
func clearItem(pos:Vector2):
	pos-=offset  # 计算相对于地图的位置
	var indexX=int(pos.x)/cellSize  # 计算X索引
	var indexY=int(pos.y)/cellSize  # 计算Y索引
	
	# 删除指定位置的方块
	for i in childNode.get_children():
		if i.mapPos.x==indexX&&i.mapPos.y==indexY:  # 匹配位置
			i.queue_free()  # 释放方块

# 保存到文件
func save2File(fileName):
	var data={"name":'',"data":[],"base":[],"author":"battlecity","description":""}  # 初始化数据结构
	
	# 收集地图数据
	for i in childNode.get_children():
		var temp={'x':i.mapPos.x,'y':i.mapPos.y,'type':i.type}  # 创建地图块数据
		data['data'].append(temp)  # 添加到数据列表
	
	var file = File.new()  # Godot 3 使用 File.new()
	file.open(fileName, File.WRITE)  # 打开文件
	file.store_string(to_json(data))  # 写入JSON数据（Godot 3 使用 to_json）
	file.flush()  # 刷新缓冲区
	file.close()  # 关闭文件


# 输入处理
func _input(event):
	if fileDialog.visible||loadDialog.visible:  # 如果对话框可见，忽略输入
		return
	
	if event is InputEventMouseButton:  # 鼠标按键事件
		if event.button_index == BUTTON_LEFT && event.pressed:  # 左键按下
			isPress=true  # 设置按下标志
			if mapRect.has_point(get_global_mouse_position()):  # 如果在地图区域内
				if currentItem=='del':
					clearItem(get_global_mouse_position())  # 删除方块
				else:
					addItem(get_global_mouse_position())  # 添加方块
		elif !event.pressed:  # 按键释放
			isPress=false  # 取消按下标志
	elif event is InputEventMouseMotion:  # 鼠标移动事件
		if isPress:  # 如果正在按下
			if mapRect.has_point(get_global_mouse_position()):  # 如果在地图区域内
				if currentItem=='del':
					clearItem(get_global_mouse_position())  # 删除方块
				else:
					addItem(get_global_mouse_position())  # 添加方块	


# 绘制网格线
func _draw():
	for i in range(27):
		draw_line(Vector2(i*cellSize,0)+offset,Vector2(i*cellSize,cellSize*26)+offset,Color.gray,0.5,true)  # 垂直线
	for i in range(27):
		draw_line(Vector2(0,i*cellSize)+offset,Vector2(cellSize*26,i*cellSize)+offset,Color.gray,0.5,true)  # 水平线


# 物品列表选中处理
func _on_ItemList_item_selected(index):
	currentItem=itemList.get_item_metadata(index)  # 获取选中的物品类型


# 保存对话框确认处理
func _on_FileDialog_confirmed():
	if fileDialog.current_file:
		save2File(fileDialog.current_path)  # 保存到文件


# 加载对话框文件选中处理
func _on_loadDialog_file_selected(path):
	loadMap(path)  # 加载地图


# 加载对话框确认处理
func _on_loadDialog_confirmed():
	var dir=loadDialog.current_dir
	var file=loadDialog.current_file
	if file:
		loadMap(dir+"/"+file)  # 加载地图

# 加载按钮点击处理
func _on_load_pressed():
	var baseDir=OS.get_executable_path().get_base_dir()  # 获取程序目录
	loadDialog.current_dir=baseDir  # 设置对话框目录
	loadDialog.popup_centered()  # 弹出对话框

# 保存按钮点击处理
func _on_save_pressed():
	var baseDir=OS.get_executable_path().get_base_dir()  # 获取程序目录
	fileDialog.current_dir=baseDir  # 设置对话框目录
	fileDialog.current_file="2025.json"  # 设置默认文件名
	fileDialog.popup_centered()  # 弹出对话框

# 清除按钮点击处理
func _on_clear_pressed():
	for i in childNode.get_children():
		i.queue_free()  # 清除所有方块
	addBaseBrick()  # 重新添加基地周边的方块

# 返回按钮点击处理
func _on_return_pressed():
	Game.changeScene("res://scene/welcome.tscn")  # 返回欢迎界面

# 保存对话框文件选中处理
func _on_FileDialog_file_selected(path):
	if fileDialog.current_file:
		save2File(fileDialog.current_path)  # 保存到文件