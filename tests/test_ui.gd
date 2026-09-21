extends SceneTree
## Integration through real Button signals. Does not prove physical touch usability.

const Main = preload("res://scenes/main.tscn")
const Store = preload("res://scripts/save_store.gd")
const PATH = "user://test_ui_isolated.json"
var ui: Control
var checks: int = 0
var failures: int = 0

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	clean()
	ui = Main.instantiate()
	ui.saves = Store.new(PATH)
	root.add_child(ui)
	await process_frame
	await process_frame
	check(ui.sim.state.stage == "order", "initial order screen")
	press("Caderno")
	check(ui.notebook, "notebook opens")
	var initial: Dictionary = ui.sim.snapshot()
	ui._act("start")
	check(ui.sim.state == initial, "notebook prevents crafting")
	press("Voltar à oficina")
	press("Pausar")
	ui._act("start")
	check(ui.sim.state == initial, "pause prevents crafting")
	press("Continuar trabalho")
	press("Começar a forjar")
	check(ui.sim.state.stage == "heat", "start button consumes material and enters forge")
	press("Aquecer · +2 tempos")
	press("Aquecer · +2 tempos")
	press("Aquecer · +2 tempos")
	check(ui.sim.state.heat == 72, "heat buttons update simulation")
	press("Levar à bigorna")
	for i in range(4):
		press("Martelar com cuidado")
	press("Seguir ao acabamento")
	for i in range(4):
		press("Polir a peça")
	press("Inspecionar trabalho")
	check(ui.sim.state.result.status == "functional", "valid UI flow reaches approved inspection")
	var save: Dictionary = ui.saves.load_state()
	check(save.stage == "inspect", "UI persists inspected piece")
	if "--capture" in OS.get_cmdline_user_args():
		await process_frame
		await RenderingServer.frame_post_draw
		var destination: String = ProjectSettings.globalize_path("res://docs/prototype-inspection.png")
		check(root.get_texture().get_image().save_png(destination) == OK, "rendered screenshot written")
	press("Entregar encomenda")
	check(ui.sim.state.completed == 1, "delivery button increments completed count")
	var coins: int = ui.sim.state.coins
	ui._act("deliver")
	check(ui.sim.state.coins == coins, "repeated UI delivery cannot pay twice")
	var restored: Dictionary = ui.saves.load_state()
	check(restored.completed == 1, "delivery persists")
	# A rejected action must keep the backup intact.
	var backup_before: String = FileAccess.get_file_as_string(PATH + ".bak")
	ui._act("inspect")
	check(FileAccess.get_file_as_string(PATH + ".bak") == backup_before,
		"invalid UI action does not rotate backup")
	ui.queue_free()
	await process_frame
	clean()
	print("UI TESTS: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)

func find_button(node: Node, caption: String) -> Button:
	if node is Button and node.text == caption:
		return node
	for child in node.get_children():
		var found: Button = find_button(child, caption)
		if found != null:
			return found
	return null

func press(caption: String) -> void:
	var button: Button = find_button(ui, caption)
	check(button != null and not button.disabled, "available button " + caption)
	if button != null and not button.disabled:
		button.pressed.emit()

func check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(label)

func clean() -> void:
	for suffix: String in ["", ".bak", ".tmp", ".rejected"]:
		if FileAccess.file_exists(PATH + suffix):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH + suffix))
