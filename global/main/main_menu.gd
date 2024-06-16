extends Node2D

@onready var transition = $Transition
var game = preload('res://game/opening.tscn')

func _on_play_pressed():
	transition.play('fade_out')

func _on_settings_pressed():
	pass # replace with function body

func _on_exit_pressed():
	get_tree().quit()

func _on_transition_animation_finished(anim_name):
	get_tree().change_scene_to_packed(game)
