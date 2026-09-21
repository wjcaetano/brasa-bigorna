extends Control

const Simulation = preload("res://scripts/forge_simulation.gd")
const SaveStore = preload("res://scripts/save_store.gd")
const WorkshopArt = preload("res://scripts/workshop_art.gd")
const INK = Color("f0e6ce")
const MUTED = Color("a9aaa0")
const GOLD = Color("e0b572")
var sim = Simulation.new()
var saves = SaveStore.new()
var paused := false
var notebook := false
var root_column: VBoxContainer
var status_label: Label
var actions: VBoxContainer
var order_box: VBoxContainer
var workshop: Control
var heat_bar: ProgressBar
var info_label: Label
var message_label: Label
var stage_label: Label
var money_label: Label
var pause_button: Button
var save_warning := ""

func _ready() -> void:
	var saved: Dictionary = saves.load_state()
	if not saved.is_empty():
		sim.restore(saved)
	if not saves.last_error.is_empty():
		save_warning = saves.last_error
	_build()
	_refresh()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		if save_warning.is_empty() and sim != null:
			saves.save_state(sim.snapshot())

func _panel(color: Color = Color("232725")) -> PanelContainer:
	var p := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(16)
	style.content_margin_left = 22
	style.content_margin_right = 22
	style.content_margin_top = 20
	style.content_margin_bottom = 20
	p.add_theme_stylebox_override("panel",style)
	return p

func _label(value: String, font_size: int = 18, color: Color = INK) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_color_override("font_color",color)
	label.add_theme_font_size_override("font_size",font_size)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

func _button(value: String, action: Callable, accent: bool = false) -> Button:
	var b := Button.new()
	b.text = value
	b.custom_minimum_size.y = 48
	b.add_theme_font_size_override("font_size",17)
	b.add_theme_color_override("font_color",Color("211e19") if accent else INK)
	for mode in ["normal", "hover", "pressed", "focus", "disabled"]:
		var box := StyleBoxFlat.new()
		box.set_corner_radius_all(9)
		box.bg_color = GOLD if accent else Color("38413b")
		if mode == "hover" or mode == "focus":
			box.bg_color = box.bg_color.lightened(0.1)
		if mode == "disabled":
			box.bg_color = Color("30332f")
		box.content_margin_left = 12
		box.content_margin_right = 12
		b.add_theme_stylebox_override(mode,box)
	b.pressed.connect(action)
	return b

func _build() -> void:
	var bg := ColorRect.new()
	bg.color = Color("151b19")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for edge in ["left","right"]:
		margin.add_theme_constant_override("margin_"+edge,32)
	for edge in ["top","bottom"]:
		margin.add_theme_constant_override("margin_"+edge,24)
	add_child(margin)
	root_column = VBoxContainer.new()
	root_column.add_theme_constant_override("separation",16)
	margin.add_child(root_column)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation",18)
	root_column.add_child(header)
	var brand := VBoxContainer.new()
	brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(brand)
	brand.add_child(_label("BRASA & BIGORNA",30,GOLD))
	brand.add_child(_label("Uma oficina. Uma vila. O prazer de criar.",16,MUTED))
	money_label = _label("",19)
	money_label.custom_minimum_size.x = 270
	header.add_child(money_label)
	var book := _button("Caderno",func(): notebook = not notebook; _refresh())
	header.add_child(book)
	pause_button = _button("Pausar",func(): paused = not paused; _refresh())
	header.add_child(pause_button)
	var steps := _panel(Color("27302a"))
	root_column.add_child(steps)
	stage_label = _label("",18,GOLD)
	steps.add_child(stage_label)
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation",16)
	root_column.add_child(body)
	var left := _panel()
	left.custom_minimum_size.x = 258
	body.add_child(left)
	var order_scroll := ScrollContainer.new()
	order_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	left.add_child(order_scroll)
	order_box = VBoxContainer.new()
	order_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	order_box.add_theme_constant_override("separation",12)
	order_scroll.add_child(order_box)
	var center := VBoxContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.add_theme_constant_override("separation",12)
	body.add_child(center)
	workshop = WorkshopArt.new()
	workshop.custom_minimum_size = Vector2(290,260)
	workshop.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.add_child(workshop)
	var meter_panel := _panel(Color("272b25"))
	center.add_child(meter_panel)
	var meters := VBoxContainer.new()
	meters.add_theme_constant_override("separation",10)
	meter_panel.add_child(meters)
	status_label = _label("",18,GOLD)
	meters.add_child(status_label)
	heat_bar = ProgressBar.new()
	heat_bar.custom_minimum_size.y = 14
	heat_bar.show_percentage = false
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("d58b56")
	fill.set_corner_radius_all(7)
	heat_bar.add_theme_stylebox_override("fill",fill)
	meters.add_child(heat_bar)
	info_label = _label("",16,MUTED)
	meters.add_child(info_label)
	var right := _panel()
	right.custom_minimum_size.x = 292
	body.add_child(right)
	var action_scroll := ScrollContainer.new()
	action_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	right.add_child(action_scroll)
	actions = VBoxContainer.new()
	actions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_theme_constant_override("separation",10)
	action_scroll.add_child(actions)
	var footer := _panel(Color("2d3027"))
	root_column.add_child(footer)
	message_label = _label("",17)
	message_label.custom_minimum_size.y = 44
	footer.add_child(message_label)
	root_column.add_child(_label("PROTÓTIPO JOGÁVEL  •  Calor em escala de jogo, sem temperaturas reais  •  Progresso local",13,MUTED))

func _clear(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()

func _act(action: String, payload: Dictionary = {}) -> void:
	if paused or notebook:
		return
	var response: Dictionary = sim.act(action,payload)
	# Rejected commands must not rotate the last known-good backup.
	if bool(response.get("ok",false)):
		save_warning = ""
		if not saves.save_state(sim.snapshot()):
			save_warning = saves.last_error + " Mantenha o jogo aberto para preservar esta sessão."
	_refresh()
	if not bool(response.get("ok",true)):
		message_label.text = str(response.get("message","Não foi possível executar esta ação."))
		if not save_warning.is_empty():
			message_label.text += "\n" + save_warning

func _action(text: String, action: String, payload: Dictionary = {}, accent: bool = false) -> void:
	var b := _button(text,func(): _act(action,payload),accent)
	b.disabled = paused or notebook
	actions.add_child(b)

func _refresh() -> void:
	if order_box == null:
		return
	var s: Dictionary = sim.state
	var stage := str(s.get("stage","order"))
	var recipe: Dictionary = sim.current_recipe()
	var names := {"order":"01  ENCOMENDA", "heat":"02  AQUECIMENTO", "shape":"03  BIGORNA", "finish":"04  ACABAMENTO", "inspect":"05  INSPEÇÃO"}
	stage_label.text = str(names.get(stage,stage)) + "    /    ENCOMENDA → FORJA → BIGORNA → ACABAMENTO → ENTREGA"
	money_label.text = "%s moedas  ·  %s reputação" % [s.get("coins",0),s.get("reputation",0)]
	pause_button.text = "Continuar" if paused else "Pausar"
	workshop.heat = float(s.get("heat",0))
	workshop.stage = stage
	workshop.queue_redraw()
	heat_bar.value = float(s.get("heat",0))
	status_label.text = "CALOR  %d / 100" % int(s.get("heat",0))
	info_label.text = "Forma: %d%%   ·   Acabamento: %d%%\nPeças entregues: %d" % [int(s.get("shape",0)),int(s.get("finish",0)),int(s.get("completed",0))]
	message_label.text = save_warning if not save_warning.is_empty() else str(s.get("message","Bem-vindo à oficina. Escolha uma encomenda para começar."))
	_clear(order_box)
	_clear(actions)
	order_box.add_child(_label("MURAL DA VILA",14,GOLD))
	if stage == "order":
		order_box.add_child(_label("Qual será a\npróxima criação?",24))
		for r in sim.recipes:
			var rid := str(r.get("id","hook"))
			var text_value := str(r.get("name",r.get("title",rid)))
			var b := _button(("• " if str(s.get("recipe_id","")) == rid else "") + text_value,func(): _act("select_order",{"recipe_id":rid}))
			b.disabled = paused or notebook
			order_box.add_child(b)
	else:
		order_box.add_child(_label(str(recipe.get("name",recipe.get("title","Encomenda"))),25))
	order_box.add_child(_label(str(recipe.get("client","Morador da vila")),16,GOLD))
	order_box.add_child(_label(str(recipe.get("description","Uma peça feita com cuidado acompanha seu dono por muitos anos.")),17,MUTED))
	order_box.add_child(HSeparator.new())
	order_box.add_child(_label("SEUS MATERIAIS",14,GOLD))
	var inv: Dictionary = s.get("inventory",{})
	order_box.add_child(_label("Ferro     %s\nAço        %s\nCobre    %s" % [inv.get("iron",0),inv.get("steel",0),inv.get("copper",0)],18))
	order_box.add_child(_label("Material escolhido: " + _material_name(str(s.get("material","iron"))),16,MUTED))
	if notebook:
		actions.add_child(_label("Caderno do ferreiro",25,GOLD))
		_recipe_notes(recipe)
		actions.add_child(_label("O tempo está parado enquanto você consulta suas notas.",16,MUTED))
		actions.add_child(_label("1. Escolha pedido e material.\n\n2. Aqueça dentro da faixa da receita.\n\n3. Trabalhe na bigorna; reaqueça quando necessário.\n\n4. Complete o acabamento e inspecione.\n\n5. Entregue ou recupere o material.",17))
		actions.add_child(_button("Voltar à oficina",func(): notebook = false; _refresh(),true))
		return
	if paused:
		actions.add_child(_label("Uma pausa junto ao fogo",25,GOLD))
		actions.add_child(_label("Sua peça pode esperar. Retome quando estiver pronto.",18,MUTED))
		actions.add_child(_button("Continuar trabalho",func(): paused = false; _refresh(),true))
		return
	match stage:
		"order":
			actions.add_child(_label("Prepare a bancada",23))
			_recipe_notes(recipe)
			actions.add_child(_label("Selecione o material. A receita ajuda a escolher; materiais incompatíveis podem falhar.",16,MUTED))
			for material in ["iron","steel","copper"]:
				_action(_material_name(material),"select_material",{"material":material},str(s.get("material","")) == material)
			_action("Começar a forjar", "start",{},true)
			_action("Comprar ferro · 8 moedas", "buy",{"material":"iron"})
			_action("Comprar aço · 12 moedas", "buy",{"material":"steel"})
			_action("Pedir auxílio à vila", "recover")
		"heat":
			actions.add_child(_label("Observe as brasas",24))
			actions.add_child(_label("Aqueça aos poucos e confira a faixa indicada na receita. Cada toque avança tempos de jogo; não é tempo real.",17,MUTED))
			_recipe_notes(recipe)
			_action("Aquecer · +2 tempos","heat",{"seconds":2},true)
			_action("Resfriar · +2 tempos","cool",{"seconds":2})
			_action("Levar à bigorna","to_anvil")
			_action("Reciclar esta peça","recycle")
		"shape":
			actions.add_child(_label("Dê forma ao metal",24))
			_recipe_notes(recipe)
			actions.add_child(_label("Trabalhe enquanto o calor estiver adequado. Reaqueça antes de continuar se esfriar.",17,MUTED))
			_action("Martelar com cuidado","hammer",{},true)
			_action("Voltar à forja","reheat")
			_action("Seguir ao acabamento","to_finish")
			_action("Reciclar esta peça","recycle")
		"finish":
			actions.add_child(_label("O cuidado final",24))
			actions.add_child(_label("Polir melhora o acabamento. Quando estiver pronto, inspecione a peça para conhecer o resultado.",18,MUTED))
			_action("Polir a peça","polish",{},true)
			_action("Inspecionar trabalho","inspect")
			_action("Reciclar esta peça","recycle")
		"inspect":
			var result: Dictionary = s.get("result",{})
			actions.add_child(_label(str(result.get("title","Inspeção concluída")),25,GOLD))
			actions.add_child(_label(str(result.get("reason","Confira o resultado do seu trabalho.")),17))
			actions.add_child(_label("Qualidade: %s\nPagamento: %s moedas" % [result.get("quality",0),result.get("reward",0)],19,MUTED))
			if str(result.get("status","failed")) == "functional":
				_action("Entregar encomenda","deliver",{},true)
			_action("Recuperar material","recycle",{},str(result.get("status","failed")) != "functional")

func _recipe_notes(recipe: Dictionary) -> void:
	var low = recipe.get("heat_min",recipe.get("min_heat",45))
	var high = recipe.get("heat_max",recipe.get("max_heat",75))
	actions.add_child(_label("FAIXA DE TRABALHO  %s–%s\nMaterial: %s" % [low,high,_material_name(str(recipe.get("material","iron")))],16,GOLD))

func _material_name(material: String) -> String:
	return str({"iron":"Ferro","steel":"Aço","copper":"Cobre"}.get(material,material))
