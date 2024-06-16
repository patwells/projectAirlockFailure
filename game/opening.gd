extends Node2D

@onready var transition = $Transition
@onready var shipFloat = $ShipFloat
@onready var nextButton = $ShipFloat/RichTextLabel

func _ready():
	transition.play('fade_in')
	shipFloat.play('opening_animation')

