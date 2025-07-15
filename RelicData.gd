extends Resource
class_name RelicData

@export var name: String = ""
@export var description: String = ""
@export var rarity: String = "Common"  # Common, Uncommon, Rare, Boss
@export var icon: String = "💎"  # 이모지 아이콘

# 유물 효과 타입
enum EffectType {
	ON_TURN_START,
	ON_CARD_PLAYED,
	ON_DAMAGE_TAKEN,
	ON_HEAL,
	PASSIVE
}

@export var effect_type: EffectType = EffectType.PASSIVE
@export var effect_value: int = 0

# 유물 효과 설명
func get_effect_description() -> String:
	match effect_type:
		EffectType.ON_TURN_START:
			return "턴 시작 시 " + str(effect_value) + " 효과"
		EffectType.ON_CARD_PLAYED:
			return "카드 사용 시 " + str(effect_value) + " 효과"
		EffectType.ON_DAMAGE_TAKEN:
			return "데미지 받을 시 " + str(effect_value) + " 효과"
		EffectType.ON_HEAL:
			return "회복 시 " + str(effect_value) + " 효과"
		EffectType.PASSIVE:
			return "지속 효과: " + str(effect_value)
		_:
			return "알 수 없는 효과" 