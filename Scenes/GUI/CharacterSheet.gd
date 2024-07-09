extends Control

@export var player: CharacterBody2D

@onready var healthlabel = $MainWindow/Panel/Health/Label
@onready var staminalabel = $MainWindow/Panel/Stamina/Label
@onready var manalabel = $MainWindow/Panel/Mana/Label
@onready var skill_point = $"MainWindow/Character Name and Level Window/Skill Point"

func _process(_delta):
	Statnames()

func Statnames():
	healthlabel.text = "Health" + "\n" + str(player.maxHealth)
	staminalabel.text = "Stamina" + "\n" + str(player.maxStamina)
	manalabel.text = "Mana" + "\n" + str(player.maxMana)
	skill_point.text = "Skill Points:  " + str(player.skillPoints)

func IncreaseHealth():
	if player.skillPoints >= 1:
		player.skillPoints -= 1
		player.maxHealth += 10


func IncreaseStamina():
	if player.skillPoints >= 1:
		player.skillPoints -= 1
		player.maxStamina += 10


func IncreaseMana():
	if player.skillPoints >= 1:
		player.skillPoints -= 1
		player.maxMana += 10



