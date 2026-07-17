extends Area2D

# 速度向量
var vec=Vector2.ZERO
# 坦克状态（空闲/开始/冻结/死亡）
var state=Game.tankstate.IDLE
# 是否无敌
var isInvincible=false
# 移动速度
var speed = 70
# 是否有船（可以在水上行驶）
var hasShip=false
# 是否冻结
var isFreeze=false
# 是否在冰块上
var isOnIce=false
# 冰块滑动次数（每帧递减）
var slideTime =20
# 子弹列表（保存当前发射的子弹）
var bullets=[]
# 最大发射子弹数
var bulletMax=1
# 生命（默认1）
var life=1
# 当前方向
var dir=Game.dir.UP
# 上次的方向
var lastDir=Game.dir.UP
# 是否停止移动
var isStop=false
# 是否可以发射子弹
var canShoot=true
# 子弹威力
var bulletPower=Game.bulletPower.NORMAL
# 坦克大小
var tankSize=28
# 护甲（最大4）
var armour=0
# 是否被摧毁
var isDestroy=false

# 单元格大小
const cellSize=16
# 地图大小
var mapSize=Vector2(cellSize*26,cellSize*26)

# 碰撞区域节点
@onready var leftArea=$left  # 左侧碰撞区域
@onready var rightArea=$right  # 右侧碰撞区域
@onready var topArea=$top  # 顶部碰撞区域
@onready var bottomArea=$bottom  # 底部碰撞区域
# 身体碰撞形状
@onready var bodyShape=$shape
# 动画节点
@onready var ani=$ani
# 射击计时器
@onready var shootTimer=$shootTimer
# 船节点
@onready var ship=$ship
# 无敌效果节点
@onready var invincible=$invincible
# 无敌计时器
@onready var invincibleTimer=$invincibleTimer
# 初始化计时器
@onready var initTimer=$initTimer

# 设置无敌状态
func startinvincible(time=8):
	isInvincible=true  # 设置无敌标志
	invincibleTimer.start(time)  # 启动无敌计时器（默认8秒）
	invincible.visible=true  # 显示无敌效果
	invincible.play("default")  # 播放无敌动画
	ani.play()  # 播放坦克动画

# 射击计时器超时处理
func _on_shoot_timer_timeout():
	canShoot=true  # 允许再次射击


# 无敌计时器超时处理
func _on_invincible_timer_timeout():
	isInvincible=false  # 取消无敌状态
	invincible.stop()  # 停止无敌动画
	invincible.visible=false  # 隐藏无敌效果
