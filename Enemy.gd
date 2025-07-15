extends Node2D

# Enemy stats
var health = 50
var max_health = 50
var block = 0

# Status effects
var vulnerable = 0  # 취약 (받는 데미지 50% 증가)
var weak = 0        # 약화 (주는 데미지 25% 감소)
var poison = 0      # 독 (턴 시작 시 데미지)

# "Intent" shows what the enemy will do next turn.
# For now, we'll just store it as a string.
var intent = "Attack"

func _ready():
	print("Enemy is ready!")

func take_damage(amount):
	# Vulnerable 상태이상이 있으면 데미지 50% 증가
	var final_damage = amount
	if vulnerable > 0:
		final_damage = int(amount * 1.5)
		print("Vulnerable! Damage increased from ", amount, " to ", final_damage)
	
	health -= final_damage
	if health < 0:
		health = 0
	print("Enemy took ", final_damage, " damage. Current health: ", health)

func gain_block(amount):
	block += amount
	print("Enemy gained ", amount, " block. Current block: ", block)

func apply_vulnerable(amount):
	vulnerable += amount
	print("Enemy gained ", amount, " Vulnerable! Total: ", vulnerable)

func apply_weak(amount):
	weak += amount
	print("Enemy gained ", amount, " Weak! Total: ", weak)

func apply_poison(amount):
	poison += amount
	print("Enemy gained ", amount, " Poison! Total: ", poison)

func start_turn():
	# 턴 시작 시 상태이상 처리
	if poison > 0:
		take_damage(poison)
		print("Poison damage dealt: ", poison)
	
	# 상태이상 감소
	if vulnerable > 0:
		vulnerable -= 1
		if vulnerable <= 0:
			vulnerable = 0
			print("Vulnerable expired!")
	
	if weak > 0:
		weak -= 1
		if weak <= 0:
			weak = 0
			print("Weak expired!")
	
	if poison > 0:
		poison -= 1
		if poison <= 0:
			poison = 0
			print("Poison expired!")

func get_status_text():
	var status = ""
	if vulnerable > 0:
		status += "Vuln:" + str(vulnerable) + " "
	if weak > 0:
		status += "Weak:" + str(weak) + " "
	if poison > 0:
		status += "Poison:" + str(poison) + " "
	return status
