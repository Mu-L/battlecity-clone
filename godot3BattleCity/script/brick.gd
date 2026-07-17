extends Area2D

# 砖块类型（0-墙壁，1-石头，2-水，3-草丛，4-冰）
export var type=Game.brickType.WALL
# 对象类型标识
export var objType=Game.objType.BRICK
# 砖块分割成4块的显示状态：上左、上右、下左、下右（1=显示，0=隐藏）
var blockMask=[1,1,1,1]

# 动画节点引用（Godot 3 使用 onready）
onready var ani=$ani

# 初始化函数
func _ready():
	setType(type)

# 设置砖块类型
func setType(value):
	if value==Game.brickType.WALL:
		ani.play("0")  # 墙壁动画
	elif value==Game.brickType.STONE:
		ani.play("1")  # 石头动画	
	elif value==Game.brickType.WATER:
		ani.play("2")  # 水动画	
	elif value==Game.brickType.BUSH:
		ani.play("3")  # 草丛动画	
		z_index=2  # 草丛在坦克上层
	elif value==Game.brickType.ICE:
		ani.play("4")  # 冰动画	

# 改变砖块类型
func changeType(value):
	self.type=value  # 更新类型
	blockMask=[1,1,1,1]  # 重置砖块分割状态
	# 更新着色器参数，控制砖块分割显示（Godot 3 使用 .set_shader_param()）
	ani.material.set_shader_param('block',Color(blockMask[0],
				blockMask[1],blockMask[2],blockMask[3]))	
	setType(value)  # 设置新类型的动画	


# 碰撞检测处理（子弹击中砖块）
func _on_brick_area_entered(area):
	if area.get('objType')==Game.objType.BULLET:  # 检测是否为子弹
		if type ==Game.brickType.WALL:  # 墙壁类型
			if area.get('dir')!=null:  # 子弹方向不为空
				var dir=area.dir  # 获取子弹方向
				# 超级子弹直接摧毁砖块
				if area.get('power')!=null && area.power==Game.bulletPower.SUPER:
					queue_free()  # 直接释放砖块
					return
				
				# 根据子弹方向破坏砖块的相应部分
				if dir==Game.dir.DOWN:  # 子弹从上方击中
					if blockMask[0]==0&&blockMask[1]==0:  # 上半部分已破坏
						blockMask[2]=0  # 破坏下左部分
						blockMask[3]=0  # 破坏下右部分
					else:	
						blockMask[0]=0  # 破坏上左部分
						blockMask[1]=0  # 破坏上右部分
				elif dir==Game.dir.UP:  # 子弹从下方击中
					if blockMask[2]==0&&blockMask[3]==0:  # 下半部分已破坏
						blockMask[0]=0  # 破坏上左部分
						blockMask[1]=0  # 破坏上右部分
					else:	
						blockMask[2]=0  # 破坏下左部分
						blockMask[3]=0  # 破坏下右部分
				elif dir==Game.dir.LEFT:  # 子弹从右侧击中
					if blockMask[1]==0&&blockMask[3]==0:  # 右半部分已破坏
						blockMask[0]=0  # 破坏上左部分
						blockMask[2]=0  # 破坏下左部分
					else:
						blockMask[1]=0  # 破坏上右部分
						blockMask[3]=0  # 破坏下右部分
				elif dir==Game.dir.RIGHT:  # 子弹从左侧击中
					if blockMask[0]==0&&blockMask[2]==0:  # 左半部分已破坏
						blockMask[1]=0  # 破坏上右部分
						blockMask[3]=0  # 破坏下右部分
					else:	
						blockMask[0]=0  # 破坏上左部分
						blockMask[2]=0  # 破坏下左部分
				
				# 检查砖块是否完全破坏
				var all=0
				for i in blockMask:
					all+=i  # 累加所有部分的状态
				if all==0:  # 所有部分都已破坏
					queue_free()  # 释放砖块
					return
				
				# 更新着色器参数，显示剩余部分
				ani.material.set_shader_param('block',Color(blockMask[0],
				blockMask[1],blockMask[2],blockMask[3]))							
		elif type==Game.brickType.STONE:  # 石头类型
			# 只有超级子弹才能摧毁石头
			if area.get('power')!=null && area.power==Game.bulletPower.SUPER:
				queue_free()  # 释放石头