extends Control

# This script will manage the overall flow of the battle, including turns,
# card drawing, and checking for win/loss conditions.

@onready var player = $PlayerContainer/Player
@onready var enemy = $EnemyContainer/Enemy
@onready var hand_container = $HandContainer
@onready var end_turn_button = $EndTurnButton
@onready var player_health_label = $PlayerContainer/PlayerHealthLabel
@onready var player_block_label = $PlayerContainer/PlayerBlockLabel
@onready var enemy_health_label = $EnemyContainer/EnemyHealthLabel
@onready var enemy_intent_label = $EnemyContainer/EnemyIntentLabel

var deck
var current_hand: Array[CardUI] = []
var current_turn = "player"
var energy = 3
var max_energy = 3
var player_strength = 0  # 플레이어의 힘 (Strength)

# Preload the Card scene for instancing
var CardScene = preload("res://Card.tscn")
var DeckScene = preload("res://Deck.gd")

func _ready():
	print("Battle Manager is ready!")
	
	# 덱 초기화
	deck = DeckScene.new()
	# initialize_deck() 함수는 존재하지 않으므로 제거
	# 덱은 _ready()에서 자동으로 초기화됨
	
	# 플레이어와 적 초기화 (initialize 함수 대신 직접 값 할당)
	player.health = 100
	player.max_health = 100
	enemy.health = 50
	enemy.max_health = 50
	
	# UI 초기화
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	
	# GameData에서 플레이어 상태 복원
	if GameData:
		player.health = GameData.player_health
		# 에너지는 새 전투 시작 시 기본값으로 초기화 (최소 3 보장)
		energy = max(3, GameData.player_energy if GameData.player_energy != null else 3)
		max_energy = max(3, GameData.player_energy if GameData.player_energy != null else 3)
		player.block = GameData.player_block
		player_strength = GameData.player_strength if GameData.player_strength != null else 0
		
		# GameData의 덱을 사용하여 덱 설정
		if GameData.player_deck.size() > 0:
			deck.set_deck(GameData.player_deck)
			print("Deck loaded from GameData with ", deck.draw_pile.size(), " cards")
		else:
			print("No deck in GameData, using default deck")
	
	# 초기 적 의도 설정
	set_enemy_intent()
	
	# 플레이어 턴 시작
	start_player_turn()

func start_player_turn():
	current_turn = "player"
	# 에너지를 기본값으로 설정하고 유물 효과 적용
	energy = 3  # 기본 에너지
	max_energy = 3  # 기본 최대 에너지
	player.block = 0  # 방어도는 턴 시작 시 사라짐
	
	# 유물 효과 적용 (턴 시작 시)
	if GameData:
		GameData.apply_relic_effects_on_turn_start()
		# 유물 효과로 인한 상태 변화를 플레이어에 반영 (에너지는 최소 3 보장)
		energy = max(3, GameData.player_energy)
		max_energy = max(3, GameData.player_energy)
		player.block = GameData.player_block
	
	# 기존 핸드의 모든 카드를 버린 카드 더미로 이동
	for card in deck.hand:
		deck.discard_pile.append(card)
	deck.hand.clear()
	print("Moved ", deck.discard_pile.size(), " cards to discard pile")
	
	# 카드 드로우 (5장으로 고정)
	deck.draw_card(5)
	
	# 카드 UI 생성
	display_cards()
	
	# 턴 종료 버튼 활성화
	end_turn_button.disabled = false
	
	print("Player turn started. Energy: ", energy, " Cards in hand: ", deck.hand.size())
	update_ui()

func start_enemy_turn():
	current_turn = "enemy"
	end_turn_button.disabled = true
	print("Enemy turn started!")
	
	# 적의 턴 시작 시 상태이상 처리
	enemy.start_turn()
	
	# 적의 행동 실행
	enemy_action()
	
	# 다음 턴을 위해 적의 의도 설정
	set_enemy_intent()
	
	# 잠시 후 플레이어 턴 시작
	await get_tree().create_timer(1.0).timeout
	start_player_turn()

func enemy_action():
	# 적의 의도에 따른 행동
	match enemy.intent:
		"Attack":
			var damage = 8
			if player.block > 0:
				if player.block >= damage:
					player.block -= damage
					damage = 0
				else:
					damage -= player.block
					player.block = 0
			
			if damage > 0:
				player.take_damage(damage)
				# 화면 흔들림 효과
				shake_screen()
			print("Enemy attacks for ", damage, " damage!")
		"Defend":
			enemy.block = 8
			print("Enemy gains 8 block!")
		_:
			print("Enemy does nothing!")

func shake_screen():
	# 간단한 화면 흔들림 효과
	var original_pos = position
	var tween = create_tween()
	tween.tween_property(self, "position", original_pos + Vector2(5, 0), 0.05)
	tween.tween_property(self, "position", original_pos + Vector2(-5, 0), 0.05)
	tween.tween_property(self, "position", original_pos + Vector2(3, 0), 0.05)
	tween.tween_property(self, "position", original_pos + Vector2(-3, 0), 0.05)
	tween.tween_property(self, "position", original_pos, 0.05)

func set_enemy_intent():
	# 간단한 AI: 랜덤하게 공격 또는 방어
	var rand_val = randf()
	if rand_val < 0.7:
		enemy.intent = "Attack"
	else:
		enemy.intent = "Defend"
	print("Enemy intent: ", enemy.intent)

func display_cards():
	# 기존 카드 UI 제거
	for child in hand_container.get_children():
		child.queue_free()
	current_hand.clear()
	
	# 새 카드 UI 생성
	var card_spacing = 170  # 카드 간격
	var start_x = (hand_container.size.x - (deck.hand.size() * card_spacing)) / 2
	
	for i in range(deck.hand.size()):
		if i >= deck.hand.size() or deck.hand[i] == null:
			continue
		var card_data = deck.hand[i]
		var card_instance = CardScene.instantiate()
		
		# 카드 크기 설정
		card_instance.custom_minimum_size = Vector2(150, 200)
		card_instance.size = Vector2(150, 200)
		
		# 카드 위치 설정
		card_instance.position = Vector2(start_x + i * card_spacing, 0)
		
		hand_container.add_child(card_instance)
		card_instance.setup(card_data)
		card_instance.card_dropped.connect(_on_card_dropped)
		current_hand.append(card_instance)
		
		print("Displayed card ", i, ": ", card_data.name, " at position: ", card_instance.position)

func _on_card_dropped(card_instance):
	if current_turn != "player":
		return
		
	var card_data = card_instance.card_data
	
	if not card_data:
		print("Error: card_data is null in _on_card_dropped.")
		return
		
	print("Card dropped: ", card_data.name)

	# Check if player has enough energy
	if energy < card_data.cost:
		print("Not enough energy to play this card!")
		return

	var drop_position = get_global_mouse_position()

	# Define placeholder target areas for Player and Enemy
	var player_node = $PlayerContainer/Player
	var enemy_node = $EnemyContainer/Enemy

	var target_size = Vector2(200, 200)
	var player_rect = Rect2(player_node.global_position - target_size / 2, target_size)
	var enemy_rect = Rect2(enemy_node.global_position - target_size / 2, target_size)

	var target_found = false

	# Process card effect based on its type and target
	if card_data.type == "Attack":
		# 공격 카드는 적에게만 사용 가능
		if enemy_rect.has_point(drop_position):
			print("Card ", card_data.name, " dropped on Enemy!")
			var base_damage = card_data.value
			var total_damage = base_damage + player_strength  # Strength 적용
			print("Base damage: ", base_damage, " + Strength: ", player_strength, " = Total: ", total_damage)
			print("Enemy block before attack: ", enemy.block)
			
			var final_damage = total_damage
			if enemy.block > 0:
				if enemy.block >= total_damage:
					enemy.block -= total_damage
					final_damage = 0
					print("All damage blocked! Enemy block remaining: ", enemy.block)
				else:
					final_damage = total_damage - enemy.block
					enemy.block = 0
					print("Partial damage blocked! Final damage: ", final_damage)
			else:
				print("No block to reduce damage")
			
			if final_damage > 0:
				print("Dealing ", final_damage, " damage to enemy")
				enemy.take_damage(final_damage)
			else:
				print("No damage dealt (fully blocked)")
			
			# 특수 효과 처리
			match card_data.name:
				"Bash":
					enemy.apply_vulnerable(2)  # 2턴간 취약
					print("Applied 2 Vulnerable to enemy!")
			
			target_found = true
		else:
			print("Attack cards must be dropped on Enemy!")
	elif card_data.type == "Skill":
		# 스킬 카드는 카드 이름에 따라 타겟 결정
		match card_data.name:
			"Defend", "Heal", "Shield", "Shrug It Off", "Armaments", "True Grit":
				# 방어 관련 카드는 플레이어에게만 사용 가능
				if player_rect.has_point(drop_position):
					print("Card ", card_data.name, " dropped on Player!")
					match card_data.name:
						"Defend":
							player.block += card_data.value
						"Heal":
							player.heal(card_data.value)
						"Shield":
							player.block += card_data.value
						"Shrug It Off":
							player.block += card_data.value
							# Draw 1 card 효과는 나중에 구현
						"Armaments":
							player.block += card_data.value
							# Upgrade 효과는 나중에 구현
						"True Grit":
							player.block += card_data.value
							# Exhaust 효과는 나중에 구현
					target_found = true
				else:
					print("Defensive cards must be dropped on Player!")
			"Iron Wave":
				# Iron Wave는 양쪽 타겟에 모두 사용 가능
				if enemy_rect.has_point(drop_position):
					print("Card ", card_data.name, " dropped on Enemy!")
					var base_damage = card_data.value
					var total_damage = base_damage + player_strength  # Strength 적용
					print("Iron Wave - Base damage: ", base_damage, " + Strength: ", player_strength, " = Total: ", total_damage)
					print("Enemy block before Iron Wave: ", enemy.block)
					
					var final_damage = total_damage
					if enemy.block > 0:
						if enemy.block >= total_damage:
							enemy.block -= total_damage
							final_damage = 0
							print("All Iron Wave damage blocked! Enemy block remaining: ", enemy.block)
						else:
							final_damage = total_damage - enemy.block
							enemy.block = 0
							print("Partial Iron Wave damage blocked! Final damage: ", final_damage)
					else:
						print("No block to reduce Iron Wave damage")
					
					if final_damage > 0:
						print("Dealing ", final_damage, " Iron Wave damage to enemy")
						enemy.take_damage(final_damage)
					else:
						print("No Iron Wave damage dealt (fully blocked)")
					target_found = true
				elif player_rect.has_point(drop_position):
					print("Card ", card_data.name, " dropped on Player!")
					player.block += card_data.value
					target_found = true
				else:
					print("Iron Wave can be dropped on either Player or Enemy!")
			"Burning Pact", "Second Wind":
				# 카드 조작 카드는 플레이어에게만 사용 가능
				if player_rect.has_point(drop_position):
					print("Card ", card_data.name, " dropped on Player!")
					# 카드 조작 효과는 나중에 구현
					target_found = true
				else:
					print("Card manipulation cards must be dropped on Player!")
			_:
				# 기타 스킬 카드는 기본적으로 플레이어에게 사용
				if player_rect.has_point(drop_position):
					print("Card ", card_data.name, " dropped on Player!")
					player.block += card_data.value
					target_found = true
				else:
					print("Skill card must be dropped on Player!")
	elif card_data.type == "Power":
		# 파워 카드는 플레이어에게만 사용 가능 (버프 효과)
		if player_rect.has_point(drop_position):
			print("Card ", card_data.name, " dropped on Player!")
			match card_data.name:
				"Inflame", "Flex":
					# Strength 효과 적용
					player_strength += card_data.value
					print("Gained ", card_data.value, " Strength! Total: ", player_strength)
				"Metallicize":
					# 턴 종료 시 방어도 효과는 나중에 구현
					pass
				"Feel No Pain":
					# Exhaust 시 방어도 효과는 나중에 구현
					pass
			target_found = true
		else:
			print("Power cards must be dropped on Player!")

	if target_found:
		# 카드 사용 처리
		energy -= card_data.cost
		
		# 카드 제거
		hand_container.remove_child(card_instance)
		current_hand.erase(card_instance)
		card_instance.queue_free()
		
		# 덱에서도 제거
		deck.hand.erase(card_data)
		deck.discard_pile.append(card_data)
		
		# 적이 죽었는지 확인
		if enemy.health <= 0:
			battle_won()
		
		update_ui()
	else:
		print("Card not dropped on valid target!")

func _on_end_turn_pressed():
	if current_turn == "player":
		start_enemy_turn()

func update_ui():
	# 플레이어 정보 업데이트
	player_health_label.text = "HP: " + str(player.health) + "/" + str(player.max_health)
	player_block_label.text = "Block: " + str(player.block)
	
	# 적 정보 업데이트
	enemy_health_label.text = "HP: " + str(enemy.health) + "/" + str(enemy.max_health)
	var enemy_status = enemy.get_status_text()
	enemy_intent_label.text = "Intent: " + enemy.intent + " | Block: " + str(enemy.block)
	if enemy_status != "":
		enemy_intent_label.text += " | " + enemy_status
	
	# 에너지 표시
	print("Energy: ", energy, "/", max_energy)
	print("Player Strength: ", player_strength)
	print("Enemy Block: ", enemy.block)
	print("Enemy Status: ", enemy_status)

func battle_won():
	print("Battle won!")
	
	# GameData 업데이트
	if GameData:
		GameData.player_health = player.health
		# 에너지는 다음 전투에서 다시 초기화되므로 저장하지 않음
		# GameData.player_energy = energy
		GameData.player_block = player.block
		GameData.player_strength = player_strength  # Strength 저장
		GameData.last_battle_result = "won"
		
		# 현재 노드를 완료 처리
		if GameData.current_node != null:
			if not GameData.completed_nodes.has(GameData.current_node):
				GameData.completed_nodes.append(GameData.current_node)
			GameData.current_node_id = GameData.current_node
			print("Completed node: ", GameData.current_node)
	
	# 보상 화면으로 전환
	get_tree().change_scene_to_file("res://RewardScreen.tscn")

func battle_lost():
	# 게임 오버 처리
	print("Game Over!")
	
	# GameData 업데이트
	if GameData:
		GameData.player_health = player.health
		GameData.player_energy = energy
		GameData.player_block = player.block
		GameData.last_battle_result = "lost"
	
	# 게임 오버 화면으로 전환
	get_tree().change_scene_to_file("res://GameOverScreen.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
