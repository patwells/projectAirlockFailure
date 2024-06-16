extends Node2D

func _on_back_pressed():
	var game = preload('res://global/menu/main_menu.tscn')
	get_tree().change_scene_to_packed(game)
