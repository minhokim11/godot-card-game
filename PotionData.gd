extends Resource
class_name PotionData

@export var name: String = ""
@export var description: String = ""
@export var rarity: String = "Common"  # Common, Uncommon, Rare
@export var icon: String = "🧪"  # 이모지 아이콘

# 물약 효과 타입
enum EffectType {
	HEAL,
	DRAW_CARDS,
	GAIN_ENERGY,
	GAIN_BLOCK,
	DAMAGE_ENEMY,
	REMOVE_DEBUFF
}

@export var effect_type: EffectType = EffectType.HEAL
@export var effect_value: int = 0

# 물약 효과 설명
func get_effect_description() -> String:
	match effect_type:
		EffectType.HEAL:
			return "체력을 " + str(effect_value) + " 회복"
		EffectType.DRAW_CARDS:
			return "카드를 " + str(effect_value) + "장 뽑음"
		EffectType.GAIN_ENERGY:
			return "에너지를 " + str(effect_value) + " 획득"
		EffectType.GAIN_BLOCK:
			return "방어도를 " + str(effect_value) + " 획득"
		EffectType.DAMAGE_ENEMY:
			return "적에게 " + str(effect_value) + " 데미지"
		EffectType.REMOVE_DEBUFF:
			return "디버프 제거"
		_:
			return "알 수 없는 효과" 