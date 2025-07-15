extends Control

@onready var floor_label = $StatsContainer/FloorLabel
@onready var cards_found_label = $StatsContainer/CardsFoundLabel
@onready var relics_found_label = $StatsContainer/RelicsFoundLabel
@onready var retry_button = $ButtonContainer/RetryButton
@onready var main_menu_button = $ButtonContainer/MainMenuButton

func _ready():
	# 버튼 연결
	retry_button.pressed.connect(_on_retry_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	
	# 게임 통계 표시
	update_stats()

func update_stats():
	# 플로어 정보
	if GameData:
		floor_label.text = "Floor Reached: " + str(GameData.current_floor)
	
	# 카드 정보
	var total_cards = GameData.player_deck.size() if GameData else 0
	cards_found_label.text = "Cards Found: " + str(total_cards)
	
	# 유물 정보
	relics_found_label.text = "Relics Found: " + str(GameData.relics.size() if GameData else 0)

func _on_retry_pressed():
	print("Retrying game...")
	# 게임 재시작
	if GameData:
		GameData.reset_game()
	get_tree().change_scene_to_file("res://MainMenu.tscn")

func _on_main_menu_pressed():
	print("Returning to main menu...")
	# 메인 메뉴로 돌아가기
	get_tree().change_scene_to_file("res://MainMenu.tscn") 