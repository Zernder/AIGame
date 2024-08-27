extends Control

@export var player: CharacterBody2D

@onready var health_potion_label = $"Panel/Health Potion/Health Potion Label"
@onready var stamina_potion_label = $"Panel/Stamina Potion/Stamina Potion Label"
@onready var mana_potion_label = $"Panel/Mana Potion/Mana Potion Label"

func _process(_delta):
	health_potion_label.text = "Health Potion"  +  "\n" + "Amount:  " + str(player.healthPotion)
	stamina_potion_label.text = "Stamina Potion"  +  "\n" + "Amount:  " + str(player.staminaPotion)
	mana_potion_label.text = "Mana Potion"  +  "\n" + "Amount:  " + str(player.manaPotion)


func HealthPotionTouched():
	if player.healthPotion >= 1:
		player.healthPotion -= 1
		player.health += min(50, player.maxHealth - player.health)


func StaminaPotionTouched():
	if player.staminaPotion >= 1:
		player.staminaPotion -= 1
		player.stamina += min(50, player.maxStamina - player.stamina)


func ManaPotionTouched():
	if player.manaPotion >= 1:
		player.manaPotion -= 1
		player.mana += min(50, player.maxMana - player.mana)


func HealthButtonPressed():
	if player.healthPotion >= 1:
		player.healthPotion -= 1
		player.health += min(50, player.maxHealth - player.health)


func StaminaButtonPressed():
	if player.staminaPotion >= 1:
		player.staminaPotion -= 1
		player.stamina += min(50, player.maxStamina - player.stamina)


func ManaButtonPressed():
	if player.manaPotion >= 1:
		player.manaPotion -= 1
		player.mana += min(50, player.maxMana - player.mana)



