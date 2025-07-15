extends Node
class_name GameDataManager

# 플레이어 상태
var player_health: int = 100
var player_max_health: int = 100
var player_gold: int = 0
var player_energy: int = 3
var player_block: int = 0
var player_strength: int = 0  # 플레이어의 힘 (Strength)

# 덱 정보
var player_deck: Array[CardData] = []
var relics: Array[RelicData] = []
var potions: Array[PotionData] = []

# 게임 진행 상태
var current_floor: int = 1
var current_node: int = 0
var current_node_id: int = 0  # 현재 플레이어가 있는 노드 ID
var completed_nodes: Array[int] = []  # 완료된 노드들
var map_nodes: Array = []
var game_started: bool = false  # 게임이 시작되었는지 추적

# 전투 결과
var last_battle_result: String = ""

func _ready():
	# 게임이 처음 시작될 때는 기본 덱을 생성하지 않음
	# New Game을 눌렀을 때만 생성됨
	pass

func initialize_starter_deck():
	# 기본 공격 카드 4장
	for i in range(4):
		var strike = CardData.new()
		strike.name = "Strike"
		strike.cost = 1
		strike.description = "Deal 6 damage."
		strike.type = "Attack"
		strike.value = 6
		player_deck.append(strike)
	
	# 기본 방어 카드 4장
	for i in range(4):
		var defend = CardData.new()
		defend.name = "Defend"
		defend.cost = 1
		defend.description = "Gain 5 block."
		defend.type = "Skill"
		defend.value = 5
		player_deck.append(defend)

func initialize_starter_items():
	# 기본 물약 1개 추가
	var health_potion = PotionData.new()
	health_potion.name = "Health Potion"
	health_potion.description = "Restore 25 HP"
	health_potion.effect_type = PotionData.EffectType.HEAL
	health_potion.effect_value = 25
	health_potion.icon = "❤️"
	potions.append(health_potion)

# 유물 관련 함수들
func add_relic(relic: RelicData):
	relics.append(relic)
	print("Gained relic: ", relic.name)

func remove_relic(relic: RelicData):
	if relics.has(relic):
		relics.erase(relic)
		print("Lost relic: ", relic.name)

func get_relic_by_name(relic_name: String) -> RelicData:
	for relic in relics:
		if relic.name == relic_name:
			return relic
	return null

# 물약 관련 함수들
func add_potion(potion: PotionData):
	potions.append(potion)
	print("Gained potion: ", potion.name)

func use_potion(potion: PotionData) -> bool:
	if potions.has(potion):
		potions.erase(potion)
		print("Used potion: ", potion.name)
		return true
	return false

func get_potion_by_name(potion_name: String) -> PotionData:
	for potion in potions:
		if potion.name == potion_name:
			return potion
	return null

# 유물 효과 적용 함수들
func apply_relic_effects_on_turn_start():
	for relic in relics:
		if relic.effect_type == RelicData.EffectType.ON_TURN_START:
			apply_relic_effect(relic)

func apply_relic_effects_on_card_played():
	for relic in relics:
		if relic.effect_type == RelicData.EffectType.ON_CARD_PLAYED:
			apply_relic_effect(relic)

func apply_relic_effects_on_damage_taken():
	for relic in relics:
		if relic.effect_type == RelicData.EffectType.ON_DAMAGE_TAKEN:
			apply_relic_effect(relic)

func apply_relic_effect(relic: RelicData):
	match relic.effect_type:
		RelicData.EffectType.ON_TURN_START:
			player_energy += relic.effect_value
			print("Relic effect: Gained ", relic.effect_value, " energy")
		RelicData.EffectType.ON_CARD_PLAYED:
			player_block += relic.effect_value
			print("Relic effect: Gained ", relic.effect_value, " block")
		RelicData.EffectType.ON_DAMAGE_TAKEN:
			player_health = min(player_health + relic.effect_value, player_max_health)
			print("Relic effect: Healed ", relic.effect_value, " HP")
		RelicData.EffectType.PASSIVE:
			# 패시브 효과는 별도로 처리
			pass

func save_game_state():
	# 게임 상태 저장 (나중에 파일 저장 기능 추가)
	pass

func load_game_state():
	# 게임 상태 로드 (나중에 파일 로드 기능 추가)
	pass

func reset_game():
	# 게임 데이터 초기화
	player_health = 100
	player_energy = 3
	player_block = 0
	player_strength = 0  # Strength 초기화
	current_floor = 1
	current_node = 0
	current_node_id = 0
	completed_nodes.clear()
	player_deck.clear()
	relics.clear()
	potions.clear()
	game_started = true  # 게임이 시작되었음을 표시
	
	# 기본 덱 생성
	initialize_starter_deck()
	initialize_starter_items()
	
	print("Game reset with basic deck of ", player_deck.size(), " cards") 
