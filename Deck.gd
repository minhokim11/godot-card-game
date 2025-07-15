extends Node

var draw_pile: Array[CardData] = []
var hand: Array[CardData] = []
var discard_pile: Array[CardData] = []
var is_initialized = false

func _ready():
	# 덱이 이미 초기화되어 있으면 건너뛰기
	if is_initialized:
		return
	
	# For testing, create some sample cards and add them to the draw pile
	var card1 = CardData.new()
	card1.name = "Strike"
	card1.cost = 1
	card1.description = "Deal 6 damage."
	card1.type = "Attack"
	card1.value = 6

	var card2 = CardData.new()
	card2.name = "Defend"
	card2.cost = 1
	card2.description = "Gain 5 block."
	card2.type = "Skill"
	card2.value = 5

	draw_pile = [card1, card1, card1, card1, card2, card2, card2, card2]
	is_initialized = true
	print("Deck ready with ", draw_pile.size(), " cards.")

func draw_card(amount: int = 1):
	for i in range(amount):
		if draw_pile.is_empty():
			# Reshuffle discard pile into draw pile if needed
			if discard_pile.is_empty():
				print("No cards left to draw!")
				return
			draw_pile = discard_pile.duplicate()
			discard_pile.clear()
			draw_pile.shuffle()
			print("Reshuffled! Draw pile now has ", draw_pile.size(), " cards.")

		var card = draw_pile.pop_front()
		hand.append(card)
		print("Drew card: ", card.name, " Cost: ", card.cost)

# 덱을 외부에서 설정할 때 사용
func set_deck(new_draw_pile: Array[CardData]):
	draw_pile.clear()
	hand.clear()
	discard_pile.clear()
	
	# 카드 데이터를 올바르게 복사
	for card in new_draw_pile:
		var new_card = CardData.new()
		new_card.name = card.name
		new_card.cost = card.cost
		new_card.description = card.description
		new_card.type = card.type
		new_card.value = card.value
		draw_pile.append(new_card)
	
	is_initialized = true
	print("Deck set with ", draw_pile.size(), " cards")
	
	# 덱 셔플
	draw_pile.shuffle()
	print("Deck shuffled")

