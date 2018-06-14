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
#var level2 = ResourceLoader.load("res://scenes/Levels_Multi/Level2.tscn")
#onready instance2 = level2.instance()
#var level3 = ResourceLoader.load("res://scenes/Levels_Multi/Level3.tscn")
#onready instance3 = level3.instance()
#var level4 = ResourceLoader.load("res://scenes/Levels_Multi/Level4.tscn")
#onready instance4 = level4.instance()
#var level5 = ResourceLoader.load("res://scenes/Levels_Multi/Level5.tscn")
#onready instance5 = level5.instance()

var levelId = null

var enemies = null
	
func _onSetEnemies(data):
	enemies = data
	
func _onSyncGame(timestamp):
	
	var root = get_tree().get_root()
	root.get_child( root.get_child_count() -1 ).free()
	
	var currentLevelInstance
	
	if levelId == 1:
		currentLevelInstance = instance1
	#elif levelId == 2:
	#	currentLevelInstane = instance2
	#elif levelId == 3:
	#	currentLevelInstane = instance3
	#elif levelId == 4:
	#	currentLevelInstane = instance4
	#elif levelId == 5:
	#	currentLevelInstane = instance5
	
	get_tree().get_root().add_child(currentLevelInstance)
	get_tree().set_current_scene(currentLevelInstance)
	
func _ready():
	Network.connect("syncGame", self, "_onSyncGame")
	Network.connect("setEnemies", self, "_onSetEnemies")
	