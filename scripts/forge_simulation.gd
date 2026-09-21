class_name ForgeSimulation
extends RefCounted

# Abstract game units. This is not a metallurgical or manufacturing reference.
const PRICES := {"iron": 8, "steel": 12, "copper": 6}
const STAGES := ["order", "heat", "shape", "finish", "inspect"]
const DEFECTS := ["wrong_material", "overheated", "worked_cold", "worked_hot"]
var recipes: Array = []
var state: Dictionary = {}

func _init() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/recipes.json"))
	if parsed is Array:
		recipes = parsed
	reset()

func reset() -> void:
	state = {"coins": 80, "reputation": 0, "completed": 0,
		"inventory": {"iron": 6, "steel": 4, "copper": 3},
		"stage": "order", "recipe_id": "hook", "material": "iron",
		"heat": 0.0, "exposure": 0.0, "shape": 0.0, "finish": 0.0,
		"defects": [], "result": {}, "message": "Escolha uma encomenda e seu material."}

func snapshot() -> Dictionary:
	return state.duplicate(true)

func current_recipe() -> Dictionary:
	for recipe in recipes:
		if recipe.id == state.recipe_id:
			return recipe.duplicate(true)
	return {}

func _reply(ok: bool, message: String) -> Dictionary:
	if ok:
		state.message = message
	return {"ok": ok, "message": message}

func _defect(code: String) -> void:
	if not state.defects.has(code):
		state.defects.append(code)

func _clear_piece() -> void:
	state.stage = "order"
	state.heat = 0.0
	state.exposure = 0.0
	state.shape = 0.0
	state.finish = 0.0
	state.defects = []
	state.result = {}

func _number(value: Variant, low: float, high: float, integral: bool = false) -> bool:
	if not (value is int or value is float):
		return false
	var n := float(value)
	return is_finite(n) and n >= low and n <= high and (not integral or n == floor(n))

# Integral of max(clamp(h + rate*t, 0, 100) - threshold, 0).
# The antiderivative preserves exposure when a time interval is partitioned.
func _excess_primitive(value: float, threshold: float) -> float:
	return 0.5 * (pow(maxf(value - threshold, 0.0), 2) - pow(maxf(value - 100.0, 0.0), 2))

func _excess_area(start: float, rate: float, seconds: float, threshold: float) -> float:
	if rate == 0.0:
		return maxf(0.0, clampf(start, 0.0, 100.0) - threshold) * seconds
	return maxf(0.0, (_excess_primitive(start + rate * seconds, threshold) - _excess_primitive(start, threshold)) / rate)

func act(action: String, payload: Dictionary = {}) -> Dictionary:
	var recipe := current_recipe()
	match action:
		"select_order":
			if state.stage != "order":
				return _reply(false, "Termine ou recicle a peça atual.")
			for candidate in recipes:
				if candidate.id == payload.get("recipe_id"):
					state.recipe_id = candidate.id
					return _reply(true, "Encomenda selecionada: " + candidate.name)
			return _reply(false, "Encomenda desconhecida.")
		"select_material":
			var material: Variant = payload.get("material")
			if state.stage != "order" or not material is String or not PRICES.has(material):
				return _reply(false, "Selecione um material válido antes de começar.")
			state.material = material
			return _reply(true, "Material selecionado. Confira a receita antes de começar.")
		"buy":
			var material: Variant = payload.get("material")
			if not material is String or not PRICES.has(material):
				return _reply(false, "Material desconhecido.")
			if state.coins < PRICES[material]:
				return _reply(false, "Moedas insuficientes.")
			state.coins -= PRICES[material]
			state.inventory[material] += 1
			return _reply(true, "Uma unidade adicionada ao estoque.")
		"recover":
			if state.stage != "order" or state.coins >= PRICES.iron:
				return _reply(false, "A ajuda é reservada a oficinas sem recursos.")
			for amount in state.inventory.values():
				if amount > 0:
					return _reply(false, "Ainda há materiais no estoque.")
			state.inventory.iron = 1
			state.material = "iron"
			state.recipe_id = "hook"
			return _reply(true, "A vila doou uma unidade de ferro para recomeçar.")
		"start":
			if state.stage != "order" or recipe.is_empty():
				return _reply(false, "Escolha uma encomenda primeiro.")
			if state.inventory[state.material] < 1:
				return _reply(false, "Este material está sem estoque.")
			state.inventory[state.material] -= 1
			state.stage = "heat"
			if state.material != recipe.material:
				_defect("wrong_material")
			return _reply(true, "Peça preparada. Aqueça até a faixa da receita.")
		"heat", "cool":
			var seconds: Variant = payload.get("seconds", 1.0)
			if state.stage != "heat" or not _number(seconds, 1, 5):
				return _reply(false, "Na forja, use intervalos entre 1 e 5 unidades.")
			var start_heat: float = state.heat
			var rate := 12.0 if action == "heat" else -8.0
			state.heat = clampf(start_heat + rate * float(seconds), 0.0, 100.0)
			state.exposure = minf(100000.0, state.exposure + _excess_area(start_heat, rate, float(seconds), float(recipe.heat_max)))
			if state.exposure > 8.0:
				_defect("overheated")
			return _reply(true, "Observe a faixa de calor da receita.")
		"to_anvil":
			if state.stage != "heat":
				return _reply(false, "A peça precisa estar na forja.")
			state.stage = "shape"
			return _reply(true, "Na bigorna: trabalhe somente dentro da faixa indicada.")
		"hammer":
			if state.stage != "shape" or state.shape >= 100:
				return _reply(false, "A peça não precisa de marteladas agora.")
			if state.heat < recipe.heat_min:
				_defect("worked_cold")
			elif state.heat > recipe.heat_max:
				_defect("worked_hot")
			state.shape = minf(100.0, state.shape + 25.0)
			state.heat = maxf(0.0, state.heat - 8.0)
			return _reply(true, "Forma trabalhada. Confira o calor antes do próximo golpe.")
		"reheat":
			if state.stage != "shape":
				return _reply(false, "Somente uma peça na bigorna pode voltar à forja.")
			state.stage = "heat"
			return _reply(true, "De volta à forja. O progresso da forma foi preservado.")
		"to_finish":
			if state.stage != "shape" or state.shape < 100:
				return _reply(false, "Conclua a forma na bigorna primeiro.")
			state.stage = "finish"
			return _reply(true, "Faça quatro passes de acabamento.")
		"polish":
			if state.stage != "finish" or state.finish >= 100:
				return _reply(false, "O acabamento não está disponível agora.")
			state.finish = minf(100.0, state.finish + 25.0)
			return _reply(true, "Acabamento melhorado.")
		"inspect":
			if state.stage != "finish" or state.finish < 100:
				return _reply(false, "Conclua o acabamento antes da inspeção.")
			state.stage = "inspect"
			state.result = _result_for(state, recipe)
			return _reply(true, state.result.reason)
		"deliver":
			if state.stage != "inspect" or state.result.get("status") != "functional":
				return _reply(false, "Somente uma peça aprovada pode ser entregue.")
			var reward: int = state.result.reward
			state.coins += reward
			state.completed += 1
			state.reputation += 1
			_clear_piece()
			return _reply(true, "Encomenda entregue! +%d moedas. A vila agradece." % reward)
		"recycle":
			if state.stage == "order":
				return _reply(false, "Não há peça para reciclar.")
			var salvage := 2
			state.coins += salvage
			_clear_piece()
			return _reply(true, "Sucata reaproveitada: +2 moedas. Vamos tentar novamente.")
	return _reply(false, "Ação desconhecida.")

func _result_for(s: Dictionary, recipe: Dictionary) -> Dictionary:
	var messages := {"wrong_material": "O material não atende à receita.",
		"overheated": "A peça acumulou exposição excessiva ao calor.",
		"worked_cold": "A peça foi trabalhada abaixo da faixa indicada.",
		"worked_hot": "A peça foi trabalhada acima da faixa indicada."}
	var reasons: Array[String] = []
	for code in s.defects:
		reasons.append(messages[code])
	var passed: bool = reasons.is_empty()
	return {"status": "functional" if passed else "failed",
		"title": "Peça aprovada" if passed else "A peça precisa ser reciclada",
		"reason": "Material, forma e processo atenderam à encomenda." if passed else " ".join(reasons),
		"reward": int(recipe.reward) if passed else 0, "quality": 100 if passed else maxi(0, 100 - reasons.size() * 35)}

# Reject malformed saves atomically; never partially assign live state.
func restore(data: Dictionary) -> bool:
	if data.size() != state.size():
		return false
	for key in state:
		if not data.has(key):
			return false
	for key in ["coins", "reputation", "completed"]:
		if not _number(data[key], 0, 1000000000, true):
			return false
	if not data.inventory is Dictionary or data.inventory.size() != PRICES.size():
		return false
	for key in PRICES:
		if not data.inventory.has(key) or not _number(data.inventory[key], 0, 1000000, true):
			return false
	if not data.stage is String or not STAGES.has(data.stage):
		return false
	if not data.material is String or not PRICES.has(data.material):
		return false
	if not data.recipe_id is String or not data.message is String or data.message.length() > 2000:
		return false
	var recipe: Dictionary = {}
	for candidate in recipes:
		if candidate.id == data.recipe_id:
			recipe = candidate
	if recipe.is_empty():
		return false
	for key in ["heat", "shape", "finish"]:
		if not _number(data[key], 0, 100):
			return false
	if not _number(data.exposure, 0, 100000) or not data.defects is Array or not data.result is Dictionary:
		return false
	var seen := {}
	for code in data.defects:
		if not code is String or not DEFECTS.has(code) or seen.has(code):
			return false
		seen[code] = true
	if data.stage == "order":
		if data.heat != 0 or data.shape != 0 or data.finish != 0 or data.exposure != 0 or not data.defects.is_empty():
			return false
	else:
		if (data.material != recipe.material) != data.defects.has("wrong_material"):
			return false
		if (data.exposure > 8.0) != data.defects.has("overheated"):
			return false
	if data.stage in ["heat", "shape"] and data.finish != 0:
		return false
	if data.stage in ["finish", "inspect"] and data.shape != 100:
		return false
	if data.stage == "inspect":
		if data.finish != 100:
			return false
		var expected := _result_for(data, recipe)
		if data.result.size() != expected.size():
			return false
		for key in expected:
			if not data.result.has(key):
				return false
			if key in ["reward", "quality"]:
				if not _number(data.result[key], 0, 1000000000, true) or int(data.result[key]) != expected[key]:
					return false
			elif not data.result[key] is String or data.result[key] != expected[key]:
				return false
	elif not data.result.is_empty():
		return false
	var candidate_state := data.duplicate(true)
	for key in ["coins", "reputation", "completed"]:
		candidate_state[key] = int(candidate_state[key])
	for key in PRICES:
		candidate_state.inventory[key] = int(candidate_state.inventory[key])
	if candidate_state.stage == "inspect":
		candidate_state.result = _result_for(candidate_state, recipe)
	state = candidate_state
	return true
