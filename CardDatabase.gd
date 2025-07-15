extends Node
class_name CardDatabase

# 카드 데이터베이스
static var all_cards: Array[CardData] = []

# 카드 초기화
static func initialize_cards():
	# 기본 카드들
	create_card("Strike", 1, "Deal 6 damage.", "Attack", 6)
	create_card("Defend", 1, "Gain 5 block.", "Skill", 5)
	
	# 공격 카드들
	create_card("Heavy Strike", 2, "Deal 12 damage.", "Attack", 12)
	create_card("Quick Strike", 0, "Deal 3 damage.", "Attack", 3)
	create_card("Bash", 2, "Deal 8 damage. Apply 2 Vulnerable.", "Attack", 8)
	create_card("Cleave", 1, "Deal 8 damage to ALL enemies.", "Attack", 8)
	
	# 스킬 카드들
	create_card("Iron Wave", 1, "Gain 5 block. Deal 5 damage.", "Skill", 5)
	create_card("Shrug It Off", 1, "Gain 8 block. Draw 1 card.", "Skill", 8)
	create_card("Armaments", 1, "Gain 5 block. Upgrade a card in your hand.", "Skill", 5)
	create_card("True Grit", 1, "Gain 7 block. Exhaust a random card from your hand.", "Skill", 7)
	
	# 파워 카드들
	create_card("Inflame", 1, "Gain 2 Strength.", "Power", 2)
	create_card("Flex", 0, "Gain 2 Strength. At the end of your turn, lose 2 Strength.", "Power", 2)
	create_card("Metallicize", 1, "At the end of your turn, gain 3 block.", "Power", 3)
	
	# 특수 카드들
	create_card("Burning Pact", 1, "Draw 2 cards. Exhaust 1 card.", "Skill", 0)
	create_card("Second Wind", 1, "Exhaust all non-Attack cards in your hand. Gain 5 block for each.", "Skill", 5)
	create_card("Feel No Pain", 1, "Whenever a card is Exhausted, gain 3 block.", "Power", 3)

static func create_card(name: String, cost: int, description: String, type: String, value: int):
	var card = CardData.new()
	card.name = name
	card.cost = cost
	card.description = description
	card.type = type
	card.value = value
	all_cards.append(card)

# 카드 풀에서 랜덤 카드 가져오기
static func get_random_card() -> CardData:
	if all_cards.is_empty():
		initialize_cards()
	return all_cards[randi() % all_cards.size()]

# 특정 타입의 카드 가져오기
static func get_random_card_by_type(card_type: String) -> CardData:
	var type_cards: Array[CardData] = []
	for card in all_cards:
		if card.type == card_type:
			type_cards.append(card)
	
	if type_cards.is_empty():
		return get_random_card()
	return type_cards[randi() % type_cards.size()]

# 카드 이름으로 찾기
static func get_card_by_name(card_name: String) -> CardData:
	for card in all_cards:
		if card.name == card_name:
			return card
	return null 