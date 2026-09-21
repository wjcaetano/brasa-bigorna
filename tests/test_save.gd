extends SceneTree

const Simulation = preload("res://scripts/forge_simulation.gd")
const Store = preload("res://scripts/save_store.gd")
const PATH: String = "user://test_save_isolated.json"
var failures: int = 0
var checks: int = 0


func _initialize() -> void:
	clean()
	var sim = Simulation.new()
	var store = Store.new(PATH)
	check(store.load_state().is_empty(), "missing save starts clean")
	check(store.save_state(sim.snapshot()), "initial save")
	check(store.load_state() == sim.snapshot(), "JSON round trip")
	var first: Dictionary = sim.snapshot()
	sim.act("buy", {"material": "iron"})
	check(store.save_state(sim.snapshot()), "second save")
	write_raw(PATH, "{broken")
	check(store.load_state() == first, "corrupt primary falls back to previous state")
	check(store.recovered_backup, "backup recovery disclosed")
	check(store.save_state(first), "recovery can save again")
	var invalid: Dictionary = first.duplicate(true)
	invalid["coins"] = -1
	check(not store.save_state(invalid), "invalid state rejected")
	check(store.load_state() == first, "rejected state did not overwrite")
	write_raw(PATH, JSON.stringify({"version": 99}))
	check(store.load_state().is_empty(), "future version not downgraded")
	check(not store.save_state(first), "future version protected from overwrite")
	clean()
	store = Store.new(PATH)
	write_raw(PATH, "x".repeat(Store.MAX_BYTES + 1))
	check(store.load_state().is_empty(), "oversized input rejected")
	clean()
	print("SAVE TESTS: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)


func check(value: bool, label: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(label)


func write_raw(path: String, value: String) -> void:
	var stream: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	stream.store_string(value)
	stream.close()


func clean() -> void:
	for suffix: String in ["", ".bak", ".tmp", ".rejected"]:
		if FileAccess.file_exists(PATH + suffix):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH + suffix))
