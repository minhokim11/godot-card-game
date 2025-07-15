extends Node
class_name MapGenerator

enum NodeType { BATTLE, ELITE_BATTLE, BOSS, SHOP, REST, EVENT }

var node_spacing = Vector2(120, 80)

func generate_map(floor_number: int = 1):
	var lines = 3
	var stages = 10
	var nodes = []
	var node_id = 0

	var special_types = [NodeType.REST, NodeType.SHOP, NodeType.EVENT]
	var special_columns = [2, 5, 8] # 0-indexed

	for line in range(lines):
		var special_type_pool = special_types.duplicate()
		for stage in range(stages):
			# 마지막 스테이지는 중앙 라인에만 노드 생성
			if stage == stages - 1 and line != 1:
				continue
				
			var pos = Vector2(stage * node_spacing.x, line * node_spacing.y)
			var node_type = NodeType.BATTLE
			
			# 마지막 스테이지는 중앙 라인에만 보스 배치
			if stage == stages - 1:
				node_type = NodeType.BOSS
			elif stage in special_columns:
				var idx = randi() % special_type_pool.size()
				node_type = special_type_pool[idx]
				special_type_pool.remove_at(idx)
			else:
				if randf() < 0.2:
					node_type = NodeType.ELITE_BATTLE
				else:
					node_type = NodeType.BATTLE
					
			var node = {
				"id": node_id,
				"type": node_type,
				"position": pos,
				"connections": [],
				"completed": false,
				"line": line,
				"stage": stage
			}
			nodes.append(node)
			node_id += 1

	for node in nodes:
		if node["stage"] < stages - 1:
			# 마지막 스테이지 직전 노드들은 중앙 보스로만 연결
			if node["stage"] == stages - 2:
				var boss_line = 1  # 중앙 라인
				var boss_id = -1
				# 실제로 존재하는 보스 노드 id 찾기
				for n in nodes:
					if n["stage"] == stages - 1 and n["line"] == boss_line and n["type"] == NodeType.BOSS:
						boss_id = n["id"]
						break
				if boss_id != -1:
					node["connections"].append(boss_id)
					nodes[boss_id]["connections"].append(node["id"])
			else:
				# 실제로 존재하는 다음 노드만 연결
				for d in [-1, 0, 1]:
					var next_line = node["line"] + d
					var next_stage = node["stage"] + 1
					var next_id = -1
					for n in nodes:
						if n["stage"] == next_stage and n["line"] == next_line:
							next_id = n["id"]
							break
					if next_id != -1:
						node["connections"].append(next_id)
						nodes[next_id]["connections"].append(node["id"])

	# 디버깅: 보스 노드 확인
	var boss_count = 0
	for node in nodes:
		if node["type"] == NodeType.BOSS:
			print("Boss node created at line: ", node["line"], " stage: ", node["stage"], " id: ", node["id"])
			boss_count += 1
	
	print("Total nodes created: ", nodes.size(), " Boss nodes: ", boss_count)
	
	return nodes 
