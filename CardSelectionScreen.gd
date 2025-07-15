extends Control

@onready var card1_instance = $CardContainer/Card1/Card1Instance
@onready var card2_instance = $CardContainer/Card2/Card2Instance
@onready var card3_instance = $CardContainer/Card3/Card3Instance
@onready var card1_button = $CardContainer/Card1/Card1Button
@onready var card2_button = $CardContainer/Card2/Card2Button
@onready var card3_button = $CardContainer/Card3/Card3Button
@onready var skip_button = $SkipButton

var CardScene = preload("res://Card.tscn")
var selected_cards: Array[CardData] = []
var card_instances: Array[Control] = []

func _ready():
	# 버튼 연결
	card1_button.pressed.connect(_on_card1_selected)
	card2_button.pressed.connect(_on_card2_selected)
	card3_button.pressed.connect(_on_card3_selected)
	skip_button.pressed.connect(_on_skip_pressed)
	
	# 카드 인스턴스 배열 설정
	card_instances = [card1_instance, card2_instance, card3_instance]
	
	# 랜덤 카드 3장 생성
	generate_random_cards()
	
	# 카드 UI 생성
	display_cards()

func generate_random_cards():
	selected_cards.clear()
	
	# 중복되지 않는 카드 3장 선택
	for i in range(3):
		var card: CardData
		var attempts = 0
		
		# 중복 방지를 위해 최대 10번 시도
		while attempts < 10:
			card = CardDatabase.get_random_card()
			if not selected_cards.has(card):
				break
			attempts += 1
		
		selected_cards.append(card)
		print("Generated card ", i + 1, ": ", card.name)

func display_cards():
	# 기존 카드 UI 제거
	for instance in card_instances:
		for child in instance.get_children():
			child.queue_free()
	
	# 새 카드 UI 생성
	for i in range(selected_cards.size()):
		var card_data = selected_cards[i]
		var card_instance = CardScene.instantiate()
		
		card_instances[i].add_child(card_instance)
		card_instance.setup(card_data)
		
		# 카드 크기 조정
		card_instance.size = Vector2(150, 200)
		card_instance.position = Vector2.ZERO

func _on_card1_selected():
	select_card(0)

func _on_card2_selected():
	select_card(1)

func _on_card3_selected():
	select_card(2)

func select_card(card_index: int):
	if card_index >= selected_cards.size():
		return
	
	var selected_card = selected_cards[card_index]
	print("Selected card: ", selected_card.name)
	
	# 선택된 카드를 덱에 추가
	GameData.player_deck.append(selected_card)
	
	# 맵으로 돌아가기
	get_tree().change_scene_to_file("res://Map.tscn")

func _on_skip_pressed():
	print("Skipped card selection")
	# 맵으로 돌아가기
	get_tree().change_scene_to_file("res://Map.tscn") 