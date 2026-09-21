extends SceneTree

const Sim = preload("res://scripts/forge_simulation.gd")
const Store = preload("res://scripts/save_store.gd")
const SAVE_PATH = "user://test_review_isolated.json"
var checks := 0
var failures := 0

func check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("REVIEW FAIL: " + label)

func make_piece(sim: RefCounted) -> void:
	check(sim.act("start").ok, "start")
	check(sim.act("heat", {"seconds": 5}).ok, "heat")
	sim.act("to_anvil")
	for i in range(3):
		sim.act("hammer")
	sim.act("reheat")
	sim.act("heat", {"seconds": 1})
	sim.act("to_anvil")
	sim.act("hammer")
	sim.act("to_finish")
	for i in range(4):
		sim.act("polish")
	sim.act("inspect")

func _initialize() -> void:
	var sim = Sim.new()
	make_piece(sim)
	check(sim.state.result.status == "functional", "legitimate production passes")
	var snapshot: Dictionary = sim.snapshot()
	var loaded = Sim.new()
	check(loaded.restore(JSON.parse_string(JSON.stringify(snapshot))), "inspected JSON numeric roundtrip")
	check(loaded.act("deliver").ok, "restored item delivered")
	var coins: int = loaded.state.coins
	check(not loaded.act("deliver").ok and loaded.state.coins == coins, "double delivery rejected")
	check(not loaded.act("recycle").ok and loaded.state.coins == coins, "post-delivery salvage rejected")
	for key in ["coins", "heat", "inventory", "stage", "defects", "result"]:
		var corrupt: Dictionary = snapshot.duplicate(true)
		corrupt[key] = null
		var before: Dictionary = loaded.snapshot()
		check(not loaded.restore(corrupt), "reject null " + key)
		check(loaded.state == before, "atomic rejection " + key)
	for value in [-1, 1.5, 1000000001, INF, NAN, "100"]:
		var corrupt: Dictionary = snapshot.duplicate(true)
		corrupt.coins = value
		check(not loaded.restore(corrupt), "reject invalid coins " + str(value))
	var reward_forgery: Dictionary = snapshot.duplicate(true)
	reward_forgery.result.reward = 999999
	check(not loaded.restore(reward_forgery), "forged reward rejected")
	var defect_forgery: Dictionary = snapshot.duplicate(true)
	defect_forgery.exposure = 9
	check(not loaded.restore(defect_forgery), "missing exposure defect rejected")
	var wrong = Sim.new()
	wrong.act("select_material", {"material": "copper"})
	make_piece(wrong)
	check(wrong.state.result.status == "failed", "wrong material always fails")
	coins = wrong.state.coins
	check(not wrong.act("deliver").ok and wrong.state.coins == coins, "failed piece cannot pay")
	check(wrong.act("recycle").ok, "failed piece salvage")
	coins = wrong.state.coins
	check(not wrong.act("recycle").ok and wrong.state.coins == coins, "double salvage rejected")
	var paused = Sim.new()
	paused.act("start")
	paused.act("heat", {"seconds": 2})
	var clone = Sim.new()
	check(clone.restore(JSON.parse_string(JSON.stringify(paused.snapshot()))), "mid-process restore")
	for instance in [paused, clone]:
		instance.act("heat", {"seconds": 2})
		instance.act("to_anvil")
		instance.act("hammer")
	check(paused.state == clone.state, "restored continuation deterministic")
	for action in ["hammer", "polish", "deliver", "inspect", "to_finish", "reheat"]:
		var fresh = Sim.new()
		var before: Dictionary = fresh.snapshot()
		check(not fresh.act(action).ok and fresh.state == before, "out-of-order action atomic " + action)
	var poor = Sim.new()
	var poverty: Dictionary = poor.snapshot()
	poverty.coins = 6
	poverty.inventory = {"iron": 0, "steel": 0, "copper": 0}
	check(poor.restore(poverty), "valid poverty state")
	check(poor.act("recover").ok, "recovery with fewer coins than useful material costs")
	check(poor.state.inventory.iron == 1, "recovery grants functional recipe material")
	check(not poor.act("recover").ok, "repeated recovery rejected")
	for suffix in ["", ".bak", ".tmp", ".rejected"]:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH + suffix))
	var store = Store.new(SAVE_PATH)
	check(store.save_state(sim.snapshot()), "inspected state written to disk")
	var recovered = Sim.new()
	check(recovered.restore(store.load_state()), "inspected state restored from disk")
	check(recovered.act("deliver").ok, "disk restored inspection pays")
	check(store.save_state(recovered.snapshot()), "post-delivery saved")
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string("{broken")
	file.close()
	check(store.load_state() == sim.snapshot() and store.recovered_backup, "inspection backup recovered after primary corruption")
	check(store.save_state(recovered.snapshot()), "save after backup recovery")
	var wrapper: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	var edited_payload: Dictionary = JSON.parse_string(wrapper.payload)
	edited_payload.coins += 100
	wrapper.payload = JSON.stringify(edited_payload)
	file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(wrapper))
	file.close()
	check(store.load_state() == sim.snapshot() and store.recovered_backup, "checksum mismatch rejects edited payload and recovers backup")
	for suffix in ["", ".bak", ".tmp", ".rejected"]:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH + suffix))
	print("QA REVIEW: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
