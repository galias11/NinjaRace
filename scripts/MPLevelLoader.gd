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
#var level2 = ResourceLoader.load("res://scenes/Levels_Multi/Level2.tscn")
#var level3 = ResourceLoader.load("res://scenes/Levels_Multi/Level3.tscn")
#var level4 = ResourceLoader.load("res://scenes/Levels_Multi/Level4.tscn")
#var level5 = ResourceLoader.load("res://scenes/Levels_Multi/Level5.tscn")

var levelId = null

var enemies = null
	
func _onSetEnemies(data):
	enemies = data
	
func _onSyncGame(timestamp):
	
	var root = get_tree().get_root()
	root.get_child( root.get_child_count() -1 ).free()
	
	var currentLevelInstance
	
	if levelId == 1:
		currentLevelInstance = level1.instance()
	#elif levelId == 2:
	#	currentLevelInstane = level2.instance()
	#elif levelId == 3:
	#	currentLevelInstane = level3.instance()
	#elif levelId == 4:
	#	currentLevelInstane = level4.instance()
	#elif levelId == 5:
	#	currentLevelInstane = level5.instance()
	
	get_tree().get_root().add_child(currentLevelInstance)
	get_tree().set_current_scene(currentLevelInstance)
	
func _ready():
	Network.connect("syncGame", self, "_onSyncGame")
	Network.connect("setEnemies", self, "_onSetEnemies")
	