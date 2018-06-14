extends Node2D

const RED = "eb1616"
const ORANGE = "eb6f16"
const BLUE = "163ceb"
const GREEN = "67eb16"
const YELLOW = "d5eb16"
const PURPLE = "c116eb"
const BROWN = "492c21"
const WHITE = "ffffff"
var arr_colors = [RED, ORANGE, BLUE, GREEN, YELLOW, PURPLE, BROWN, WHITE]

var level1 = ResourceLoader.load("res://scenes/Levels_Multi/Level1.tscn")
onready var instance1 = level1.instance()
var level2 = ResourceLoader.load("res://scenes/Levels_Multi/Level2.tscn")
onready var instance2 = level2.instance()
var level3 = ResourceLoader.load("res://scenes/Levels_Multi/Level3.tscn")
onready var instance3 = level3.instance()
var level4 = ResourceLoader.load("res://scenes/Levels_Multi/Level4.tscn")
onready var instance4 = level4.instance()
var level5 = ResourceLoader.load("res://scenes/Levels_Multi/Level5.tscn")
onready var instance5 = level5.instance()

var levelId = null

var enemies = null
	
func _onSetEnemies(data):
	enemies = data
	
func _onSyncGame(timestamp):
	
	get_tree().get_current_scene().free()
	
	var currentLevelInstance
	
	if levelId == 1:
		currentLevelInstance = instance1
	elif levelId == 2:
		currentLevelInstance = instance2
	elif levelId == 3:
		currentLevelInstance = instance3
	elif levelId == 4:
		currentLevelInstance = instance4
	elif levelId == 5:
		currentLevelInstance = instance5
	
	get_tree().get_root().add_child(currentLevelInstance)
	get_tree().set_current_scene(currentLevelInstance)
	
func finishGame():
	get_tree().get_current_scene().queue_free()
	if levelId == 1:
		instance1 = level1.instance()
	elif levelId == 2:
		instance2 = level2.instance()
	elif levelId == 3:
		instance3 = level3.instance()
	elif levelId == 4:
		instance4 = level4.instance()
	elif levelId == 5:
		instance5 = level5.instance()

func _ready():
	Network.connect("syncGame", self, "_onSyncGame")
	Network.connect("setEnemies", self, "_onSetEnemies")
	