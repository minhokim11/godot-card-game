extends Control
class_name CardUI

# This will hold the entire data object for the card
var card_data: CardData

# UI Node references
@onready var name_label = $NameLabel
@onready var cost_label = $CostLabel
@onready var description_label = $DescriptionLabel

signal card_dropped(card_instance)

var is_aiming = false
var original_scale = Vector2(1.0, 1.0)
var original_position = Vector2.ZERO
var is_hovered = false
var card_id = 0
static var next_card_id = 0

# This function will be called by BattleManager to set up the card
func setup(data: CardData):
	card_data = data
	card_id = next_card_id
	next_card_id += 1
	
	if card_data:
		if name_label:
			name_label.text = card_data.name
		if cost_label:
			cost_label.text = str(card_data.cost)
		if description_label:
			description_label.text = card_data.description
	else:
		print("Error: CardData not set for CardUI!")

func _ready():
	original_scale = scale
	original_position = position
	
	# 마우스 필터를 STOP으로 설정하여 이벤트가 통과하지 않도록 함
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# 시그널은 Card.tscn에서 이미 연결되어 있으므로 여기서는 연결하지 않음
	print("Card ", card_id, " ready with mouse_filter: ", mouse_filter, " at position: ", position)

func _draw():
	# Draw a 2-pixel thick, opaque red border around the card's rect
	draw_rect(Rect2(Vector2.ZERO, size), Color(1, 0, 0, 1), false, 2.0)
	
	if is_aiming:
		# Draw a line from the card's center to the mouse position
		var from = size / 2
		var to = get_local_mouse_position()
		draw_line(from, to, Color(1, 0.5, 0.5, 0.8), 5.0)

func _process(delta):
	if is_aiming:
		# Redraw the control every frame to update the line
		queue_redraw()

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_aiming = true
			# Bring the card to the front visually while aiming
			move_to_front()
		else:
			if is_aiming:
				is_aiming = false
				card_dropped.emit(self)
				# Force a final redraw to clear the line
				queue_redraw()

func _on_mouse_entered():
	if is_hovered:
		return  # 이미 호버 상태면 중복 처리 방지
	
	is_hovered = true
	print("Card ", card_id, " hovered: ", card_data.name if card_data else "Unknown", " at position: ", position)
	
	# 애니메이션으로 카드 확대 (위치 변경 없이)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	move_to_front()

func _on_mouse_exited():
	if not is_hovered:
		return  # 이미 호버 해제 상태면 중복 처리 방지
	
	is_hovered = false
	print("Card ", card_id, " unhovered: ", card_data.name if card_data else "Unknown", " at position: ", position)
	
	# 애니메이션으로 카드 원래 크기로 복원 (위치 변경 없이)
	var tween = create_tween()
	tween.tween_property(self, "scale", original_scale, 0.1)
