extends Control

@onready var new_game_button = $MenuContainer/NewGameButton
@onready var continue_button = $MenuContainer/ContinueButton
@onready var settings_button = $MenuContainer/SettingsButton
@onready var quit_button = $MenuContainer/QuitButton

func _ready():
	# 버튼 연결
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Continue 버튼 활성화/비활성화
	update_continue_button()

func update_continue_button():
	# 게임이 시작되었고 덱이 있으면 Continue 버튼 활성화
	if GameData and GameData.game_started and GameData.player_deck.size() > 0:
		continue_button.disabled = false
	else:
		continue_button.disabled = true

func _on_new_game_pressed():
	print("Starting new game...")
	
	# 게임 데이터 초기화
	if GameData:
		print("GameData found, resetting game...")
		GameData.reset_game()
		print("Game reset completed. Deck size: ", GameData.player_deck.size())
	else:
		print("ERROR: GameData is null!")
	
	# 맵으로 이동
	print("Attempting to change scene to Map.tscn...")
	var result = get_tree().change_scene_to_file("res://Map.tscn")
	print("Scene change result: ", result)

func _on_continue_pressed():
	print("Continuing game...")
	
	# 맵으로 이동
	get_tree().change_scene_to_file("res://Map.tscn")

func _on_settings_pressed():
	print("Settings not implemented yet")
	# 설정 화면으로 이동 (나중에 구현)

func _on_quit_pressed():
	print("Quitting game...")
	get_tree().quit() 
