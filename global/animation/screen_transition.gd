extends CanvasLayer

signal on_transition_finished

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer

func _ready():
	color_rect.visible = false
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(animation_name):
	if animation_name == 'fade_out':
		on_transition_finished.emit()
		animation_player.play('fade_in')
	elif animation_name == 'fade_in':
		color_rect.visible = false

func fade():
	color_rect.visible = true
	animation_player.play('fade_out')
