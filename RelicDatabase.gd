extends Node
class_name RelicDatabase

# 유물 데이터베이스
static var all_relics: Array[RelicData] = []

# 유물 초기화
static func initialize_relics():
	# 일반 유물들
	create_relic("Vajra", "Start each combat with 1 Strength.", "Common", "⚡", RelicData.EffectType.ON_TURN_START, 1)
	create_relic("Orichalcum", "If you end your turn with 6 or less Block, gain 4 Block.", "Common", "🛡️", RelicData.EffectType.PASSIVE, 4)
	create_relic("Bronze Scales", "When you take damage, deal 3 damage back.", "Common", "🐉", RelicData.EffectType.ON_DAMAGE_TAKEN, 3)
	
	# 희귀 유물들
	create_relic("Bag of Marbles", "At the start of each combat, apply 1 Vulnerable to ALL enemies.", "Uncommon", "🔴", RelicData.EffectType.ON_TURN_START, 1)
	create_relic("Kunai", "Every time you play 3 Attacks in a single turn, gain 1 Dexterity.", "Uncommon", "🗡️", RelicData.EffectType.ON_CARD_PLAYED, 1)
	create_relic("Shuriken", "Every time you play 3 Attacks in a single turn, gain 1 Strength.", "Uncommon", "⭐", RelicData.EffectType.ON_CARD_PLAYED, 1)
	
	# 레어 유물들
	create_relic("Ginger", "You can no longer become Weakened.", "Rare", "🫚", RelicData.EffectType.PASSIVE, 0)
	create_relic("Tungsten Rod", "Whenever you would lose HP, lose 1 less.", "Rare", "🔩", RelicData.EffectType.PASSIVE, 1)
	create_relic("Calipers", "At the start of your turn, lose 15 Block rather than all of it.", "Rare", "📏", RelicData.EffectType.PASSIVE, 15)

static func create_relic(name: String, description: String, rarity: String, icon: String, effect_type: RelicData.EffectType, effect_value: int):
	var relic = RelicData.new()
	relic.name = name
	relic.description = description
	relic.rarity = rarity
	relic.icon = icon
	relic.effect_type = effect_type
	relic.effect_value = effect_value
	all_relics.append(relic)

# 유물 풀에서 랜덤 유물 가져오기
static func get_random_relic() -> RelicData:
	if all_relics.is_empty():
		initialize_relics()
	return all_relics[randi() % all_relics.size()]

# 특정 희귀도의 유물 가져오기
static func get_random_relic_by_rarity(rarity: String) -> RelicData:
	var rarity_relics: Array[RelicData] = []
	for relic in all_relics:
		if relic.rarity == rarity:
			rarity_relics.append(relic)
	
	if rarity_relics.is_empty():
		return get_random_relic()
	return rarity_relics[randi() % rarity_relics.size()]

# 유물 이름으로 찾기
static func get_relic_by_name(relic_name: String) -> RelicData:
	for relic in all_relics:
		if relic.name == relic_name:
			return relic
	return null 