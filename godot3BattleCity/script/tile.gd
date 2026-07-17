extends Node2D

# 砖块类型（0-墙壁，1-石头，2-水，3-草丛，4-冰）
export var type=Game.brickType.WALL
# 动画节点引用（Godot 3 使用 onready）
onready var ani=$ani
# 在编辑地图中的位置
var mapPos=Vector2.ZERO


# 初始化函数
func _ready():
	# 根据类型播放对应动画
	if type==Game.brickType.WALL:
		ani.play("0")  # 墙壁动画
	elif type==Game.brickType.STONE:
		ani.play("1")  # 石头动画	
	elif type==Game.brickType.WATER:
		ani.play("2")  # 水动画	
	elif type==Game.brickType.BUSH:
		ani.play("3")  # 草丛动画	
	elif type==Game.brickType.ICE:
		ani.play("4")  # 冰动画	