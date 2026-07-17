extends Node2D

# 道具出现音效节点
@onready var bouns=$bouns
# 增加生命音效节点
@onready var addLives=$addLives
# 获得道具音效节点
@onready var getBouns=$GetBouns
# 爆炸音效节点
@onready var bomb=$bomb
# 奖励音效节点
@onready var award=$award
# 分数音效节点
@onready var point=$point
# 背景音乐节点
@onready var music=$music


# 播放道具出现音效
func playBouns():
	bouns.play()


# 播放增加生命音效
func playAddLives():
	addLives.play()


# 播放获得道具音效
func playGetBouns():
	getBouns.play()


# 播放爆炸音效
func playBomb():
	bomb.play()


# 播放奖励音效
func playAward():
	award.play()


# 播放分数音效
func playPoint():
	point.play()


# 播放背景音乐
func playMusic():
	music.play()
