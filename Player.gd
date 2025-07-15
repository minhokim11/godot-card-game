extends Node2D

# Player stats
var health = 100
var max_health = 100
var energy = 3
var max_energy = 3
var block = 0

func _ready():
	print("Player is ready!")

func take_damage(amount):
	health -= amount
	if health < 0:
		health = 0
	print("Player took ", amount, " damage. Current health: ", health)

func gain_block(amount):
	block += amount
	print("Player gained ", amount, " block. Current block: ", block)

func spend_energy(amount):
	energy -= amount
	print("Player spent ", amount, " energy. Current energy: ", energy)
