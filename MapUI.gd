extends Control

# MapGenerator의 NodeType enum 복사 선언
enum NodeType { BATTLE, ELITE_BATTLE, BOSS, SHOP, REST, EVENT }

@onready var map_container = $MapContainer
@onready var floor_label = $FloorLabel
@onready var health_label = $PlayerInfo/HealthLabel
@onready var gold_label = $PlayerInfo/GoldLabel
@onready var deck_size_label = $PlayerInfo/DeckSizeLabel

var map_generator
var current_map_nodes = []
var node_buttons = []
var current_node_id = 0  # 현재 플레이어가 있는 노드 ID
var completed_nodes = []  # 완료된 노드들

# 노드 버튼 씬 프리로드
var NodeButtonScene = preload("res://MapNodeButton.tscn")

# null-safe 딕셔너리/배열 접근 함수
func safe_get(dict, key, default_value = null):
	if dict == null:
		return default_value
	if typeof(dict) == TYPE_DICTIONARY and dict.has(key):
		return dict[key]
	if typeof(dict) == TYPE_ARRAY and key < dict.size():
		return dict[key]
	return default_value

func _ready():
	print("MapUI: _ready() called")
	map_generator = MapGenerator.new()
	generate_new_map()
	center_map()
	update_ui()
	print("MapUI: Initialization completed")
	
	# 전투에서 돌아온 경우 맵 상태 업데이트
	if GameData != null and GameData.last_battle_result == "won":
		print("Returning from battle victory, updating map state...")
		# 맵 상태 업데이트 (다른 노드들의 접근성 재계산)
		for i in range(node_buttons.size()):
			if i < current_map_nodes.size() and node_buttons[i] != null and current_map_nodes[i] != null:
				update_node_button_state(node_buttons[i], current_map_nodes[i])
		
		# 연결선 다시 그리기
		draw_connections()
		
		# 전투 결과 초기화
		GameData.last_battle_result = ""

func generate_new_map():
	# 기존 노드 버튼들 제거
	for button in node_buttons:
		if button != null:
			button.queue_free()
	node_buttons.clear()
	
	# 새 맵 생성
	if map_generator != null:
		var floor_number = 1
		if GameData != null:
			floor_number = GameData.current_floor
		current_map_nodes = map_generator.generate_map(floor_number)
	else:
		current_map_nodes = []
	
	# 완료된 노드들 복원 (게임 데이터에서)
	if GameData != null:
		completed_nodes = GameData.completed_nodes.duplicate() if GameData.completed_nodes != null else []
		current_node_id = GameData.current_node_id
	else:
		completed_nodes = []
		current_node_id = 0
	
	# 노드 버튼들 생성
	for node in current_map_nodes:
		if node == null:
			continue
			
		var button = NodeButtonScene.instantiate()
		if button == null:
			continue
			
		if map_container != null:
			map_container.add_child(button)
			# Control 노드의 자식으로 추가할 때는 offset 사용
			var node_pos = safe_get(node, "position")
			if node_pos != null:
				button.offset_left = node_pos.x - 25  # 버튼 크기의 절반만큼 조정
				button.offset_top = node_pos.y - 25
				button.offset_right = node_pos.x + 25
				button.offset_bottom = node_pos.y + 25
			button.setup(node)
			button.node_clicked.connect(_on_node_clicked)
			node_buttons.append(button)
			
			var position_str = "null"
			if node_pos != null:
				position_str = str(node_pos)
			print("Created node button at position: ", position_str, " with offset: ", button.offset_left, ", ", button.offset_top)
			
			# 노드 상태에 따라 버튼 활성화/비활성화
			update_node_button_state(button, node)
	
	# 연결선 그리기
	draw_connections()
	
	# 디버깅: 생성된 노드들 정보 출력
	print("Map generation completed. Total nodes: ", current_map_nodes.size())
	var stage_count = {}
	for node in current_map_nodes:
		if node != null:
			var node_type = safe_get(node, "type")
			var node_id = safe_get(node, "id")
			var node_stage = safe_get(node, "stage")
			var node_line = safe_get(node, "line")
			
			# 스테이지별 노드 수 카운트
			if node_stage != null:
				if not stage_count.has(node_stage):
					stage_count[node_stage] = 0
				stage_count[node_stage] += 1
			
			print("Node ID: ", node_id, " Type: ", node_type, " Stage: ", node_stage, " Line: ", node_line)
	
	# 스테이지별 노드 수 출력
	print("Nodes per stage:")
	for stage in stage_count.keys():
		print("Stage ", stage, ": ", stage_count[stage], " nodes")

func center_map():
	if map_container == null:
		return

	var screen_size = get_viewport().get_visible_rect().size
	if screen_size == Vector2.ZERO:
		screen_size = Vector2(1920, 1080)

	var stages = 10
	var lines = 3

	# 화면 크기에 따라 margin, node_spacing 자동 조정
	var margin = int(screen_size.x * 0.07)
	var min_spacing = 90
	var max_spacing = 160
	var node_spacing_x = clamp((screen_size.x - margin * 2) / (stages - 1), min_spacing, max_spacing)
	var node_spacing_y = 80

	# 맵 크기 계산
	var map_width = node_spacing_x * (stages - 1) + margin * 2
	var map_height = node_spacing_y * lines + margin * 2

	# 중앙보다 약간 아래로 내리기 (60px)
	var offset_x = (screen_size.x - map_width) / 2
	var offset_y = (screen_size.y - map_height) / 2 + 60

	map_container.position = Vector2(offset_x, offset_y)

	# 노드 위치도 spacing에 맞게 재배치
	for button in node_buttons:
		if button and button.node_data:
			var node = button.node_data
			var stage = node["stage"] if node.has("stage") else 0
			var line = node["line"] if node.has("line") else 0
			var x = margin + stage * node_spacing_x
			var y = margin + line * node_spacing_y
			button.offset_left = x - 25
			button.offset_top = y - 25
			button.offset_right = x + 25
			button.offset_bottom = y + 25

	print("Map centered - Screen size: ", screen_size, " Map size: ", Vector2(map_width, map_height), " Offset: ", Vector2(offset_x, offset_y), " Node spacing: ", node_spacing_x)

func _notification(what):
	# 화면 크기가 변경될 때 맵을 다시 중앙에 배치
	if what == NOTIFICATION_RESIZED:
		center_map()

func update_node_button_state(button, node):
	if button == null:
		return
		
	if node == null:
		button.disabled = true
		button.modulate = Color(0.5, 0.5, 0.5)
		return
	
	var is_accessible = false

	# 첫 번째 열(시작점)은 모두 활성화
	var node_stage = safe_get(node, "stage")
	if node_stage != null and node_stage == 0:
		is_accessible = true
	# 이미 완료된 노드는 항상 활성화
	else:
		var node_id = safe_get(node, "id")
		if node_id != null and completed_nodes.has(node_id):
			is_accessible = true
		# 마지막으로 완료한 노드에서 연결된 노드만 활성화
		elif completed_nodes.size() > 0:
			var last_completed_id = safe_get(completed_nodes, completed_nodes.size() - 1)
			var last_node = get_node_by_id(last_completed_id)
			if last_node != null:
				var last_connections = safe_get(last_node, "connections", [])
				if last_connections != null and last_connections.has(node_id):
					is_accessible = true

	button.disabled = not is_accessible
	var node_id = safe_get(node, "id")
	if node_id != null and completed_nodes.has(node_id):
		button.modulate = Color(0.5, 0.5, 0.5)
	else:
		button.modulate = Color(1, 1, 1)

func get_node_by_id(node_id):
	if node_id == null:
		return null
	for node in current_map_nodes:
		if node == null:
			continue
		var node_id_check = safe_get(node, "id")
		if node_id_check != null and node_id_check == node_id:
			return node
	return null

func get_node_button_by_id(node_id):
	for button in node_buttons:
		if button and button.node_data and button.node_data.has("id") and button.node_data["id"] == node_id:
			return button
	return null

func get_node_id_safe(node):
	if node == null:
		return null
	if typeof(node) != TYPE_DICTIONARY:
		return null
	if not node.has("id"):
		return null
	if node["id"] == null:
		return null
	return node["id"]

func draw_connections():
	# 기존 연결선 제거
	if map_container != null:
		for child in map_container.get_children():
			if child is Line2D:
				child.queue_free()

	# 현재 진행 상황에 따라 연결선 그리기
	if completed_nodes.size() == 0:
		# 시작점: 1열 노드에서 2열로 가는 모든 연결선 표시
		for node in current_map_nodes:
			if node == null:
				continue
			var node_stage = safe_get(node, "stage")
			var node_connections = safe_get(node, "connections", [])
			if node_stage != null and node_stage == 0 and node_connections != null:
				for connection_id in node_connections:
					if connection_id == null:
						continue
					var from_btn = get_node_button_by_id(node["id"])
					var to_btn = get_node_button_by_id(connection_id)
					if from_btn and to_btn:
						var line = Line2D.new()
						map_container.add_child(line)
						var from_pos = Vector2(from_btn.offset_left + 25, from_btn.offset_top + 25)
						var to_pos = Vector2(to_btn.offset_left + 25, to_btn.offset_top + 25)
						line.add_point(from_pos)
						line.add_point(to_pos)
						line.width = 2
						line.default_color = Color.WHITE
	else:
		# 완료된 노드들 중 가장 최근에 완료된 노드에서만 연결선 표시
		var last_completed_id = safe_get(completed_nodes, completed_nodes.size() - 1)
		var last_node = get_node_by_id(last_completed_id)
		if last_node != null:
			var connections = safe_get(last_node, "connections", [])
			if connections != null:
				for connection_id in connections:
					if connection_id == null:
						continue
					if not completed_nodes.has(connection_id):
						var from_btn = null
						var last_node_id = get_node_id_safe(last_node)
						if last_node_id != null:
							from_btn = get_node_button_by_id(last_node_id)
						var to_btn = null
						if connection_id != null:
							to_btn = get_node_button_by_id(connection_id)
						if from_btn != null and to_btn != null:
							var line = Line2D.new()
							map_container.add_child(line)
							var from_pos = Vector2(from_btn.offset_left + 25, from_btn.offset_top + 25)
							var to_pos = Vector2(to_btn.offset_left + 25, to_btn.offset_top + 25)
							line.add_point(from_pos)
							line.add_point(to_pos)
							line.width = 2
							line.default_color = Color.WHITE

func _on_node_clicked(node_data):
	if node_data == null:
		print("MapUI: Node data is null!")
		return
		
	var node_type = "unknown"
	var node_id = "unknown"
	var node_type_raw = safe_get(node_data, "type")
	if node_type_raw != null:
		node_type = str(node_type_raw)
	var node_id_raw = safe_get(node_data, "id")
	if node_id_raw != null:
		node_id = str(node_id_raw)
	print("MapUI: Node clicked - Type: ", node_type, " ID: ", node_id)
	
	# 노드가 접근 가능한지 확인
	if node_id_raw == null:
		print("MapUI: Node ID is null!")
		return
		
	var is_accessible = is_node_accessible(node_id_raw)
	print("MapUI: Node accessibility check - ID: ", node_id_raw, " Accessible: ", is_accessible)
	
	if not is_accessible:
		print("MapUI: Node is not accessible!")
		return
	
	# 클릭한 노드에 시각적 피드백
	highlight_clicked_node(node_data)
	
	# 노드 타입에 따른 처리
	if node_type_raw == null:
		print("MapUI: Node type is missing!")
		return
		
	# 기존 node_type 변수를 실제 값으로 업데이트
	node_type = node_type_raw
	match node_type:
		NodeType.BATTLE, NodeType.ELITE_BATTLE:
			print("Starting battle...")
			start_battle(node_data)
		NodeType.BOSS:
			print("Starting boss battle...")
			start_boss_battle(node_data)
		NodeType.SHOP:
			print("Opening shop...")
			open_shop()
		NodeType.REST:
			print("Resting at campfire...")
			rest_at_campfire(node_data)
		NodeType.EVENT:
			print("Triggering event...")
			trigger_event(node_data)

func is_node_accessible(node_id):
	if node_id == null:
		print("is_node_accessible: node_id is null")
		return false
	
	# 노드 정보 가져오기
	var node = get_node_by_id(node_id)
	if node == null:
		print("is_node_accessible: node not found for id: ", node_id)
		return false
	
	# 첫 번째 열(stage == 0)의 모든 노드는 시작 노드로 접근 가능
	var node_stage = safe_get(node, "stage")
	if node_stage != null and node_stage == 0:
		print("is_node_accessible: node ", node_id, " is start node (stage 0)")
		return true
	elif completed_nodes.has(node_id):  # 이미 완료된 노드
		print("is_node_accessible: node ", node_id, " is already completed")
		return true
	else:
		# 이전에 완료된 노드와 연결되어 있는지 확인
		for completed_id in completed_nodes:
			if completed_id == null:
				continue
			var completed_node = get_node_by_id(completed_id)
			if completed_node != null:
				var completed_connections = safe_get(completed_node, "connections", [])
				if completed_connections != null and completed_connections.has(node_id):
					print("is_node_accessible: node ", node_id, " is connected to completed node ", completed_id)
					return true
		print("is_node_accessible: node ", node_id, " is not accessible")
		return false

func highlight_clicked_node(node_data):
	if node_data == null:
		return
	var node_id = safe_get(node_data, "id")
	if node_id == null:
		return
		
	# 클릭한 노드 찾기
	for button in node_buttons:
		if button != null and button.node_data != null:
			var button_node_id = safe_get(button.node_data, "id")
			if button_node_id != null and button_node_id == node_id:
				# 클릭 효과 애니메이션
				var tween = create_tween()
				tween.tween_property(button, "scale", Vector2(1.3, 1.3), 0.1)
				tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)
				break

func start_battle(node_data):
	# 전투 씬으로 전환
	if GameData != null:
		var node_id = safe_get(node_data, "id")
		if node_id != null:
			GameData.current_node = node_id
	get_tree().change_scene_to_file("res://Battle.tscn")

func start_boss_battle(node_data):
	# 보스 전투 씬으로 전환 (나중에 별도 보스 씬 생성)
	if GameData != null:
		var node_id = safe_get(node_data, "id")
		if node_id != null:
			GameData.current_node = node_id
	get_tree().change_scene_to_file("res://Battle.tscn")

func open_shop():
	# 상점 씬으로 전환 (나중에 구현)
	print("Shop not implemented yet")

func rest_at_campfire(node_data):
	# 휴식 처리
	if GameData != null:
		var node_id = safe_get(node_data, "id")
		if node_id != null:
			GameData.player_health = min(GameData.player_health + 30, GameData.player_max_health)
			complete_node(node_id)
	
	# 노드 상태 업데이트 (다른 노드들의 접근성 재계산)
	for i in range(node_buttons.size()):
		if i < current_map_nodes.size() and node_buttons[i] != null and current_map_nodes[i] != null:
			update_node_button_state(node_buttons[i], current_map_nodes[i])
	
	update_ui()
	print("Rested at campfire. HP restored!")

func trigger_event(node_data):
	# 이벤트 처리 (나중에 구현)
	print("Event not implemented yet")
	var node_id = safe_get(node_data, "id")
	if node_id != null:
		complete_node(node_id)
	
	# 노드 상태 업데이트 (다른 노드들의 접근성 재계산)
	for i in range(node_buttons.size()):
		if i < current_map_nodes.size() and node_buttons[i] != null and current_map_nodes[i] != null:
			update_node_button_state(node_buttons[i], current_map_nodes[i])

func complete_node(node_id):
	# 노드 완료 처리
	if node_id == null:
		return
	if not completed_nodes.has(node_id):
		completed_nodes.append(node_id)
		current_node_id = node_id
		
		# GameData에 저장
		if GameData != null:
			GameData.completed_nodes = completed_nodes.duplicate()
			GameData.current_node_id = current_node_id
		
		print("Node ", node_id, " completed!")

func update_ui():
	if GameData == null:
		print("GameData is null!")
		return
		
	if floor_label != null:
		floor_label.text = "Floor " + str(GameData.current_floor)
	if health_label != null:
		health_label.text = "HP: " + str(GameData.player_health) + "/" + str(GameData.player_max_health)
	if gold_label != null:
		gold_label.text = "Gold: " + str(GameData.player_gold)
	
	var deck_size = 0
	if GameData.player_deck != null:
		deck_size = GameData.player_deck.size()
	if deck_size_label != null:
		deck_size_label.text = "Deck: " + str(deck_size) + " cards"
	
	# 유물 정보 업데이트
	var relic_info = "Relics: " + str(GameData.relics.size() if GameData.relics != null else 0)
	if GameData.relics != null and GameData.relics.size() > 0:
		relic_info += " ("
		for i in range(min(3, GameData.relics.size())):
			var relic = safe_get(GameData.relics, i)
			if relic != null:
				relic_info += relic.icon
		relic_info += ")"
	
	var relic_label = $PlayerInfo/RelicLabel
	if relic_label != null:
		relic_label.text = relic_info
	
	# 물약 정보 업데이트
	var potion_info = "Potions: " + str(GameData.potions.size() if GameData.potions != null else 0)
	if GameData.potions != null and GameData.potions.size() > 0:
		potion_info += " ("
		for i in range(min(3, GameData.potions.size())):
			var potion = safe_get(GameData.potions, i)
			if potion != null:
				potion_info += potion.icon
		potion_info += ")"
	
	var potion_label = $PlayerInfo/PotionLabel
	if potion_label != null:
		potion_label.text = potion_info

func _on_battle_won():
	# 전투 승리 후 처리
	if GameData != null:
		complete_node(GameData.current_node)
		
		# 맵 상태 업데이트 (다른 노드들의 접근성 재계산)
		for i in range(node_buttons.size()):
			if i < current_map_nodes.size() and node_buttons[i] != null and current_map_nodes[i] != null:
				update_node_button_state(node_buttons[i], current_map_nodes[i])
		
		# 연결선 다시 그리기
		draw_connections()
		
	update_ui()
	
	# 보상 화면 표시
	show_reward_screen()

func show_reward_screen():
	# 보상 화면으로 전환
	get_tree().change_scene_to_file("res://RewardScreen.tscn") 
