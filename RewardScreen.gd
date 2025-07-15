extends Control

@onready var gold_button = $RewardContainer/GoldReward/GoldButton
@onready var card_button = $RewardContainer/CardReward/CardButton
@onready var potion_button = $RewardContainer/PotionReward/PotionButton
@onready var continue_button = $ContinueButton

var reward_selected = false

func _ready():
	# 버튼 연결
	gold_button.pressed.connect(_on_gold_selected)
	card_button.pressed.connect(_on_card_selected)
	potion_button.pressed.connect(_on_potion_selected)
	continue_button.pressed.connect(_on_continue_pressed)
	
	# 보상 금액 설정
	var gold_amount = randi_range(20, 35)
	$RewardContainer/GoldReward/GoldLabel.text = str(gold_amount) + " Gold"
	
	# 물약 보상 설정
	var random_potion = PotionDatabase.get_random_potion()
	$RewardContainer/PotionReward/PotionLabel.text = random_potion.name

func _on_gold_selected():
	if reward_selected:
		return
	
	reward_selected = true
	var gold_text = $RewardContainer/GoldReward/GoldLabel.text
	var gold_parts = gold_text.split(" ") if gold_text != null else []
	var gold_amount = int(gold_parts[0]) if gold_parts.size() > 0 else 0
	GameData.player_gold += gold_amount
	print("Gained ", gold_amount, " gold!")
	
	# 버튼 비활성화
	gold_button.disabled = true
	card_button.disabled = true
	potion_button.disabled = true

func _on_card_selected():
	if reward_selected:
		return
	
	reward_selected = true
	# 카드 선택 화면으로 전환
	print("Opening card selection screen...")
	get_tree().change_scene_to_file("res://CardSelectionScreen.tscn")

func _on_potion_selected():
	if reward_selected:
		return
	
	reward_selected = true
	# 물약 획득
	var potion_name = $RewardContainer/PotionReward/PotionLabel.text
	var potion = PotionDatabase.get_potion_by_name(potion_name)
	if potion:
		GameData.add_potion(potion)
		print("Gained potion: ", potion.name)
	else:
		# 기본 체력 회복
		GameData.player_health = min(GameData.player_health + 25, GameData.player_max_health)
		print("Gained health potion! HP restored!")
	
	# 버튼 비활성화
	gold_button.disabled = true
	card_button.disabled = true
	potion_button.disabled = true

func _on_continue_pressed():
	# 맵으로 돌아가기
	get_tree().change_scene_to_file("res://Map.tscn") 