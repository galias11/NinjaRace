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

var levelId = null

var enemies = null
	
func _onSetEnemies(data):
	enemies = data
	
func _onSyncGame(timestamp):
	var scene = ResourceLoader.load("res://scenes/Levels_Multi/Level" + str(levelId) + ".tscn")
	var sceneInstance = scene.instance()
	get_tree().get_root().add_child(sceneInstance)
	get_tree().set_current_scene(sceneInstance)
	
func _ready():
	Network.connect("syncGame", self, "_onSyncGame")
	Network.connect("setEnemies", self, "_onSetEnemies")
	