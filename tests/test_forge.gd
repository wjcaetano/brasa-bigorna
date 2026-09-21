extends SceneTree
const Simulation = preload("res://scripts/forge_simulation.gd")
var checks := 0
var failures := 0

func check(value: bool, label: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(label)

func ok(sim: RefCounted, action: String, payload: Dictionary = {}) -> void:
	check(sim.act(action, payload).ok, "Action failed: " + action)

func finish_hook(sim: RefCounted) -> void:
	ok(sim, "heat", {"seconds": 5.0})
	ok(sim, "to_anvil")
	for i in range(3):
		ok(sim, "hammer")
	ok(sim, "reheat")
	ok(sim, "heat", {"seconds": 1.0})
	ok(sim, "to_anvil")
	ok(sim, "hammer")
	ok(sim, "to_finish")
	for i in range(4):
		ok(sim, "polish")
	ok(sim, "inspect")

func _initialize() -> void:
	var sim := Simulation.new()
	check(sim.recipes.size() == 3, "Recipes loaded")
	var before: Dictionary = sim.snapshot()
	check(not sim.act("hammer").ok, "Illegal transition rejected")
	check(sim.snapshot() == before, "Invalid action atomic")
	ok(sim, "start")
	check(sim.state.inventory.iron == 5, "Start consumes exactly one unit")
	finish_hook(sim)
	check(sim.state.result.status == "functional", "Correct process succeeds")
	var valid_save: Dictionary = sim.snapshot()
	check(sim.restore(valid_save), "Valid save restores")
	ok(sim, "deliver")
	check(sim.state.coins == 104 and sim.state.completed == 1, "Delivery reward")
	check(not sim.act("deliver").ok and sim.state.coins == 104, "No double payment")
	ok(sim, "select_material", {"material": "copper"})
	ok(sim, "start")
	finish_hook(sim)
	check(sim.state.result.status == "failed", "Wrong material fails")
	check(not sim.act("deliver").ok, "Failed item cannot deliver")
	ok(sim, "recycle")
	check(sim.state.coins == 106, "Recycling pays salvage only")
	ok(sim, "select_material", {"material": "iron"})
	ok(sim, "start")
	ok(sim, "heat", {"seconds": 5.0})
	ok(sim, "heat", {"seconds": 5.0})
	check(sim.state.defects.has("overheated"), "Excess exposure recorded")
	ok(sim, "cool", {"seconds": 5.0})
	check(sim.state.defects.has("overheated"), "Cooling cannot erase damage")
	before = sim.snapshot()
	check(not sim.act("heat", {"seconds": NAN}).ok, "NaN action rejected")
	check(sim.snapshot() == before, "NaN rejection atomic")
	var invalid: Dictionary = before.duplicate(true)
	invalid.heat = NAN
	check(not sim.restore(invalid), "NaN save rejected")
	check(sim.snapshot() == before, "Invalid restore atomic")
	invalid = before.duplicate(true)
	invalid.inventory.iron = -1
	check(not sim.restore(invalid), "Negative inventory rejected")
	invalid = valid_save.duplicate(true)
	invalid.result.reward = 999999
	check(not sim.restore(invalid), "Forged reward rejected")
	invalid = before.duplicate(true)
	invalid.stage = "unknown"
	check(not sim.restore(invalid), "Unknown state rejected")
	var detached: Dictionary = sim.snapshot()
	detached.inventory.iron = 999
	check(sim.state.inventory.iron != 999, "Snapshots are detached")
	sim.reset()
	before = sim.snapshot()
	before.coins = 0
	before.inventory = {"iron": 0, "steel": 0, "copper": 0}
	check(sim.restore(before), "Broke state valid")
	ok(sim, "recover")
	check(not sim.act("recover").ok, "Assistance cannot stack")
	check(sim.state.inventory.iron == 1 and sim.state.coins == 0, "Assistance gives material only")
	# JSON round trip must accept the parser's numeric representation.
	var roundtrip: Variant = JSON.parse_string(JSON.stringify(sim.snapshot()))
	check(sim.restore(roundtrip), "JSON snapshot roundtrip")
	for coins in [6, 7]:
		sim.reset()
		var stranded: Dictionary = sim.snapshot()
		stranded.coins = coins
		stranded.inventory = {"iron": 0, "steel": 0, "copper": 0}
		check(sim.restore(stranded), "Stranded save accepted")
		ok(sim, "recover")
		check(sim.state.inventory.iron == 1 and sim.state.coins == coins, "Recovery available below useful material cost")
	var whole := Simulation.new()
	var split := Simulation.new()
	ok(whole, "start")
	ok(split, "start")
	ok(whole, "heat", {"seconds": 5.0})
	ok(split, "heat", {"seconds": 5.0})
	ok(whole, "heat", {"seconds": 5.0})
	for i in range(5):
		ok(split, "heat", {"seconds": 1.0})
	check(is_equal_approx(whole.state.exposure, split.state.exposure), "Heating partition invariant above cap")
	check(is_equal_approx(whole.state.exposure, 1625.0 / 24.0), "Heating integral exact")
	var exposure_before: float = whole.state.exposure
	ok(whole, "cool", {"seconds": 5.0})
	for i in range(5):
		ok(split, "cool", {"seconds": 1.0})
	check(is_equal_approx(whole.state.exposure, split.state.exposure), "Cooling partition invariant")
	check(is_equal_approx(whole.state.exposure - exposure_before, 39.0625), "Cooling contributes exact excess area")
	print("FORGE TESTS: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
