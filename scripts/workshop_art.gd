extends Control

var heat: float = 0.0
var stage: String = "order"
const GOLD = Color("d9a95b")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _draw() -> void:
	var scale_factor := minf(size.x / 450.0, size.y / 370.0)
	var offset := Vector2((size.x - 450.0 * scale_factor) / 2, (size.y - 370.0 * scale_factor) / 2)
	draw_set_transform(offset, 0, Vector2.ONE * scale_factor)
	# Plaster, exposed timber, window and a soft pool of firelight.
	draw_style_box(_box(Color("242322"), 18), Rect2(0, 0, 450, 370))
	for x in [30, 225, 424]:
		draw_rect(Rect2(x, 0, 12, 310), Color("343029"))
	draw_rect(Rect2(0, 304, 450, 66), Color("302922"))
	for y in [322, 346, 365]:
		draw_line(Vector2(0,y),Vector2(450,y),Color("41362c"),2)
	draw_style_box(_box(Color("182a34"), 32),Rect2(303,26,101,136))
	for i in range(9):
		var x := 311.0 + float(i % 4) * 24
		var y := 40.0 + float(i / 4) * 38
		draw_line(Vector2(x,y),Vector2(x-6,y+15),Color("47606d"),1)
	draw_rect(Rect2(350,29,7,131),Color("60503a"))
	draw_rect(Rect2(305,90,98,7),Color("60503a"))
	draw_rect(Rect2(296,157,115,9),Color("806747"))
	# Forge stones, chimney and arched opening.
	draw_rect(Rect2(93,0,82,74),Color("4b4942"))
	for y in [16,40,63]:
		draw_line(Vector2(95,y),Vector2(172,y),Color("302f2c"),3)
	draw_style_box(_box(Color("635e50"),35),Rect2(49,64,169,230))
	draw_style_box(_box(Color("151918"),38),Rect2( seventy(),94,124,143))
	for y in [87,121,155,189,224,261]:
		draw_line(Vector2(51,y),Vector2( seventy()-2,y),Color("444239"),3)
		draw_line(Vector2(196,y),Vector2(215,y),Color("444239"),3)
	var glow := Color("d27c36")
	glow.a = 0.07 + heat / 800.0
	draw_circle(Vector2(132,214),104,glow)
	draw_rect(Rect2(76,218,113,13),Color("713b28"))
	for i in range(5):
		var x := 85.0 + i * 22.0
		var tip := 177.0 - (i % 3) * 14.0 - heat * 0.16
		draw_colored_polygon(PackedVector2Array([Vector2(x-11,220),Vector2(x+2,tip),Vector2(x+14,220)]),Color("d8763f"))
		draw_colored_polygon(PackedVector2Array([Vector2(x-5,220),Vector2(x+3,tip+20),Vector2(x+9,220)]),Color("efc47b"))
	draw_rect(Rect2(39,236,187,18),Color("827664"))
	draw_rect(Rect2(82,272,105,17),Color("37332c"))
	# Tools on the wall.
	draw_rect(Rect2(240,39,10,96),Color("795c3d"))
	draw_style_box(_box(Color("94948a"),3),Rect2(225,43,40,19))
	draw_line(Vector2(282,46),Vector2(278,116),Color("898b80"),5)
	draw_line(Vector2(269,48),Vector2(278,116),Color("898b80"),5)
	# Workbench and anvil silhouette.
	draw_rect(Rect2(272,240,142,17),Color("956d45"))
	draw_rect(Rect2(280,258,13,67),Color("674b32"))
	draw_rect(Rect2(393,258,13,67),Color("674b32"))
	draw_rect(Rect2(303,226,80,9),Color("697778"))
	draw_circle(Vector2(398,230),7,Color("b58351"))
	draw_style_box(_box(Color("6a4932"),9),Rect2(192,280,67,61))
	draw_colored_polygon(PackedVector2Array([Vector2(162,246),Vector2(266,246),Vector2(292,252),Vector2(266,267),Vector2(240,267),Vector2(240,282),Vector2(259,290),Vector2(185,290),Vector2(206,279),Vector2(206,266),Vector2(178,264)]),Color("9aaba6"))
	draw_line(Vector2(169,248),Vector2(267,248),Color("d1d7c9"),3)
	if stage != "order":
		var metal := Color("d99b57") if heat > 40 else Color("c0c6b4")
		draw_line(Vector2(200,239),Vector2(251,239),metal,6)
	draw_set_transform(Vector2.ZERO)

func seventy() -> float:
	return 70.0

func _box(color: Color, radius: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(radius)
	return box
