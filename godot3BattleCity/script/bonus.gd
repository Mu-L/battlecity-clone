extends Area2D

# 对象类型标识
var objType=Game.objType.BONUS
# 道具类型（默认星星）
var type=Game.bonusType.STAR
# 动画节点引用（Godot 3 使用 onready）
onready var ani=$ani

# 初始化函数
func _ready():
	# 根据道具类型播放对应动画
	if type==Game.bonusType.BOAT:
		ani.play("0")  # 船道具动画
	elif type==Game.bonusType.CLOCK:
		ani.play("1")  # 时钟道具动画
	elif type==Game.bonusType.GRENADE:
		ani.play("2")  # 手榴弹道具动画
	elif type==Game.bonusType.GUN:
		ani.play("3")  # 枪道具动画
	elif type==Game.bonusType.HELMET:
		ani.play("4")  # 头盔道具动画	
	elif type==Game.bonusType.SHOVEL:
		ani.play("5")  # 铲子道具动画	
	elif type==Game.bonusType.STAR:
		ani.play("6")  # 星星道具动画	
	elif type==Game.bonusType.TANK:	
		ani.play("7")  # 坦克道具动画


# 设置随机道具类型
func setRandomType():
	var arr=[Game.bonusType.BOAT,Game.bonusType.CLOCK,
	Game.bonusType.GRENADE,Game.bonusType.GUN,Game.bonusType.HELMET,
	Game.bonusType.SHOVEL,Game.bonusType.STAR,Game.bonusType.TANK]
	type=arr[randi()%arr.size()]  # 随机选择一种道具类型	