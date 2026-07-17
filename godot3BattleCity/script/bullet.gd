extends Area2D

# 对象类型标识
var objType=Game.objType.BULLET
# 子弹方向
var dir=Game.dir.UP
# 子弹威力（普通/快速/超级）
var power=Game.bulletPower.NORMAL
# 子弹速度
var speed=160
# 子弹所有者类型（玩家/敌人）
var own=Game.objType.PLAYER
# 子弹所有者ID
var ownId=0
# 玩家ID（仅玩家子弹使用）
var playerId=Game.playerId.p1
# 速度向量
var vec=Vector2.ZERO
# 是否被摧毁
var isDestroy=false
# 子弹状态
var state=Game.objState.START

# 单元格大小
const cellSize=16
# 地图大小
var mapSize=Vector2(cellSize*26,cellSize*26)

# 爆炸效果预制体
var explode=preload("res://scene/explode.tscn")
# 精灵节点（Godot 3 使用 Sprite）
onready var sprite=$Sprite
# 碰撞形状节点
onready var shape=$shape
# 音效节点
onready var sound=$sound

# 初始化函数
func _ready():
	# 根据方向设置子弹的朝向和速度向量
	if dir==Game.dir.UP:
		sprite.flip_v=true  # 翻转精灵
		vec=Vector2(0,-speed)  # 向上移动
	elif dir==Game.dir.DOWN:
		vec=Vector2(0,speed)  # 向下移动
	elif dir==Game.dir.LEFT:
		vec=Vector2(-speed,0)  # 向左移动
		sprite.rotation_degrees=90  # 旋转精灵
		shape.rotation_degrees=90  # 旋转碰撞形状
	elif dir==Game.dir.RIGHT:
		vec=Vector2(speed,0)  # 向右移动
		sprite.rotation_degrees=-90  # 旋转精灵
		shape.rotation_degrees=-90  # 旋转碰撞形状


# 设置子弹威力
func setPower(value):
	if value==Game.bulletPower.NORMAL:
		speed=180  # 普通子弹速度
	elif value==Game.bulletPower.FAST:
		speed=380  # 快速子弹速度
	elif value==Game.bulletPower.SUPER:
		speed=380  # 超级子弹速度（速度同快速，但威力更大）
	power=value  # 保存威力值		

# 物理过程处理
func _physics_process(delta):
	if state==Game.objState.START:  # 如果子弹状态为开始
		position+=vec*delta  # 根据速度向量移动
		
		# 边界检查：子弹超出地图范围时销毁
		if position.x<0||position.x>mapSize.x:  # 水平边界
			if own==Game.objType.PLAYER:
				addexplode(true)  # 玩家子弹播放音效
			else:
				addexplode()  # 敌人子弹不播放音效	
		if position.y<0||position.y>mapSize.y:  # 垂直边界
			if own==Game.objType.PLAYER:
				addexplode(true)  # 玩家子弹播放音效
			else:
				addexplode()  # 敌人子弹不播放音效	

# 爆炸效果
func addexplode(playSound=false):
	isDestroy=true  # 设置摧毁标志
	state=Game.objState.IDLE  # 设置状态为空闲
	visible=false  # 隐藏子弹
	set_deferred('monitorable',false)  # 禁用碰撞检测
	set_deferred('monitoring',false)  # 禁用碰撞检测
	
	var temp = explode.instance()  # Godot 3 使用 .instance() 替代 .instantiate()
	temp.position=position  # 设置爆炸位置
	Game.map.addOther(temp)  # 添加到地图
	
	if playSound:
		sound.play()  # 播放音效
		yield(sound,"finished")  # Godot 3 使用 yield 替代 await
		queue_free()  # 释放子弹
	else:
		queue_free()  # 直接释放子弹		


# 碰撞检测处理（Godot 3 使用 _on_bullet_area_entered）
func _on_bullet_area_entered(area):
	if area.get_instance_id()==ownId||isDestroy:  # 忽略自身和已销毁的子弹
		return	
	
	if own==Game.objType.ENEMY:  # 敌人子弹
		if area.get('objType')==Game.objType.PLAYER:  # 击中玩家
			addexplode()  # 添加爆炸效果
	elif own==Game.objType.PLAYER:  # 玩家子弹
		if area.get('objType')==Game.objType.ENEMY:  # 击中敌人
			addexplode()  # 添加爆炸效果		

	# 击中子弹或基地
	if area.get('objType')==Game.objType.BULLET||area.get('objType')==Game.objType.BASE:
		if area.get('objType')==Game.objType.BULLET:
			if area.get('own')!=own:  # 敌人与敌人之间子弹不抵消
				call_deferred('queue_free')  # 延迟释放子弹	
		else:		
			call_deferred('queue_free')  # 击中基地，延迟释放子弹	
	elif area.get('objType')==Game.objType.BRICK:
		if area.get('type')==Game.brickType.WALL||area.get('type')==Game.brickType.STONE:
			# 玩家普通子弹无法摧毁石头
			if own==Game.objType.PLAYER&&power!=Game.bulletPower.SUPER\
				&&area.get('type')==Game.brickType.STONE:
				addexplode(true)  # 玩家子弹播放音效
			else:		
				addexplode()  # 添加爆炸效果	