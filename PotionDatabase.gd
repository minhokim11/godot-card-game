extends Node
class_name PotionDatabase

# 물약 데이터베이스
static var all_potions: Array[PotionData] = []

# 물약 초기화
static func initialize_potions():
	# 일반 물약들
	create_potion("Health Potion", "Restore 25 HP", "Common", "❤️", PotionData.EffectType.HEAL, 25)
	create_potion("Energy Potion", "Gain 2 Energy", "Common", "⚡", PotionData.EffectType.GAIN_ENERGY, 2)
	create_potion("Block Potion", "Gain 12 Block", "Common", "🛡️", PotionData.EffectType.GAIN_BLOCK, 12)
	
	# 희귀 물약들
	create_potion("Fire Potion", "Deal 20 damage to ALL enemies", "Uncommon", "🔥", PotionData.EffectType.DAMAGE_ENEMY, 20)
	create_potion("Swift Potion", "Draw 2 cards", "Uncommon", "💨", PotionData.EffectType.DRAW_CARDS, 2)
	create_potion("Steroid Potion", "Gain 5 Strength", "Uncommon", "💪", PotionData.EffectType.GAIN_ENERGY, 5)
	
	# 레어 물약들
	create_potion("Elixir", "Remove all debuffs", "Rare", "🧪", PotionData.EffectType.REMOVE_DEBUFF, 0)
	create_potion("Fairy in a Bottle", "When you would die, heal to 30% of your Max HP instead", "Rare", "🧚", PotionData.EffectType.HEAL, 30)

static func create_potion(name: String, description: String, rarity: String, icon: String, effect_type: PotionData.EffectType, effect_value: int):
	var potion = PotionData.new()
	potion.name = name
	potion.description = description
	potion.rarity = rarity
	potion.icon = icon
	potion.effect_type = effect_type
	potion.effect_value = effect_value
	all_potions.append(potion)

# 물약 풀에서 랜덤 물약 가져오기
static func get_random_potion() -> PotionData:
	if all_potions.is_empty():
		initialize_potions()
	return all_potions[randi() % all_potions.size()]

# 특정 희귀도의 물약 가져오기
static func get_random_potion_by_rarity(rarity: String) -> PotionData:
	var rarity_potions: Array[PotionData] = []
	for potion in all_potions:
		if potion.rarity == rarity:
			rarity_potions.append(potion)
	
	if rarity_potions.is_empty():
		return get_random_potion()
	return rarity_potions[randi() % rarity_potions.size()]

# 물약 이름으로 찾기
static func get_potion_by_name(potion_name: String) -> PotionData:
	for potion in all_potions:
		if potion.name == potion_name:
			return potion
	return null 