extends Button

# MapGenerator의 NodeType enum 복사 선언
enum NodeType { BATTLE, ELITE_BATTLE, BOSS, SHOP, REST, EVENT }

@onready var icon_label = $Icon

var node_data

signal node_clicked(node_data)

func _ready():
	# 버튼의 pressed 시그널을 _on_pressed 함수에 연결
	pressed.connect(_on_pressed)

func setup(node):
	node_data = node
	update_appearance()

func update_appearance():
	if not node_data:
		return
	
	# 노드 타입에 따른 아이콘과 색상 설정
	match node_data.type:
		NodeType.BATTLE:
			icon_label.text = "⚔"
			modulate = Color.RED
		NodeType.ELITE_BATTLE:
			icon_label.text = "⚔"
			modulate = Color.ORANGE
		NodeType.BOSS:
			icon_label.text = "👹"
			modulate = Color.PURPLE
		NodeType.SHOP:
			icon_label.text = "💰"
			modulate = Color.YELLOW
		NodeType.REST:
			icon_label.text = "🔥"
			modulate = Color.GREEN
		NodeType.EVENT:
			icon_label.text = "❓"
			modulate = Color.CYAN
	
	# 완료된 노드는 회색으로 표시
	if node_data.completed:
		modulate = Color.GRAY

func _on_pressed():
	if node_data:
		print("Node button pressed: ", node_data.type, " at position: ", node_data.position)
		# 버튼이 비활성화되어 있어도 클릭 이벤트 발생
		node_clicked.emit(node_data)
	else:
		print("Node button pressed but node_data is null!") 
