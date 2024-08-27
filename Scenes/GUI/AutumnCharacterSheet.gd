extends Control

@export var player: CharacterBody2D


func _process(_delta):
	Statnames()
	UIProcess()


func _input(_event):
	OpenCharacterSheet()


#region Character Sheet

@onready var charactersheet = $"."
@onready var healthlabel = $"MainWindow/VBoxContainer/Health,Stamina,Mana/Health Panel/healthlabel"
@onready var staminalabel = $"MainWindow/VBoxContainer/Health,Stamina,Mana/Stamina Panel/staminalabel"
@onready var manalabel = $"MainWindow/VBoxContainer/Health,Stamina,Mana/Mana Panel/manalabel"
@onready var physicaldamagelabel = $"MainWindow/VBoxContainer/Damage/Physical Damage Panel/physicaldamagelabel"
@onready var magicaldamagelabel = $"MainWindow/VBoxContainer/Damage/Magical Damage/magicaldamagelabel"
@onready var physicaldefenselabel = $"MainWindow/VBoxContainer/Defense/Physical Defense/physicaldefenselabel"
@onready var magicaldefenselabel = $"MainWindow/VBoxContainer/Defense/Magical Defense/magicaldefenselabel"
@onready var skillpointlabel = $"MainWindow/Character Name and Level Window/skillpointlabel"
@onready var name_and_level_label = $"MainWindow/Character Name and Level Window/Name and Level Label"



func OpenCharacterSheet():
	if Input.is_action_just_pressed("Character Sheet"):
		if charactersheet.visible:
			charactersheet.hide()
		else:
			charactersheet.show()


func Statnames():
	name_and_level_label.text = "Autumn Sakilera" + "\n" + "Level: " + str(player.level)
	healthlabel.text = "Health: " + "\n" + str(player.maxHealth)
	staminalabel.text = "Stamina: " + "\n" + str(player.maxStamina)
	manalabel.text = "Mana: " + "\n" + str(player.maxMana)
	physicaldamagelabel.text =  "Physical Damage:" + "\n" + str(player.physicalDamage)
	magicaldamagelabel.text =  "Magical Damage:" + "\n" + str(player.magicalDamage)
	physicaldefenselabel.text =  "Physical Defense:" + "\n" + str(player.physicalDefense)
	magicaldefenselabel.text =  "Magical Defense:" + "\n" + str(player.magicalDefense)
	skillpointlabel.text = "Stat Points:  " + str(player.skillPoints)

func IncreaseHealth():
	if player.skillPoints >= 1:
		player.skillPoints -= 1
		player.maxHealth += 5
		player.health += 5


func IncreaseStamina():
	if player.skillPoints >= 1:
		player.skillPoints -= 1
		player.maxStamina += 10
		player.stamina += 10


func IncreaseMana():
	if player.skillPoints >= 1:
		player.skillPoints -= 1
		player.maxMana += 5
		player.mana += 5

func IncreasePhysicalDamage():
	if player.skillPoints >= 1:
		player.skillPoints -= 1
		player.physicalDamage += 5


func IncreaseMagicalDamage():
	if player.skillPoints >= 1:
		player.skillPoints -= 1
		player.magicalDamage += 5


func IncreasePhysicalDefense():
	if player.skillPoints >= 1:
		player.skillPoints -= 1
		player.physicalDefense += 5

func IncreaseMagicalDefense():
	if player.skillPoints >= 1:
		player.skillPoints -= 1
		player.magicalDefense += 5

#endregion


#region ScreenUI

@onready var health_bar = $"ScreenUI/Health Bar"
@onready var stamina_bar = $"ScreenUI/Stamina Bar"
@onready var mana_bar = $"ScreenUI/Mana Bar"
@onready var expbar = $ScreenUI/Expbar
@onready var health_label = $"ScreenUI/Health Bar/Health Label"
@onready var stamina_label = $"ScreenUI/Stamina Bar/Stamina Label"
@onready var mana_label = $"ScreenUI/Mana Bar/Mana Label"


func UIProcess():
	health_bar.value = player.health
	health_bar.max_value = player.maxHealth
	health_label.text = str(player.health) + "/" + str(player.maxHealth)
	
	stamina_bar.value = player.stamina
	stamina_bar.max_value = player.maxStamina
	stamina_label.text = str(player.stamina) + "/" + str(player.maxStamina)
	
	mana_bar.value = player.mana
	mana_bar.max_value = player.maxMana
	mana_label.text = str(player.mana) + "/" + str(player.maxMana)
	
	expbar.value = player.currentxp
	expbar.max_value = player.requiredxp


#endregion

