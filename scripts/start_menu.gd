extends CanvasLayer
var g
var screen:Control
var guide:PanelContainer
var menu_buttons=[]
var setup_panel:PanelContainer
var difficulty_choices={}
func _init(game):g=game;layer=90
func _ready():
 screen=Control.new();screen.size=Vector2(1440,900);screen.mouse_filter=Control.MOUSE_FILTER_STOP;add_child(screen)
 var cover=TextureRect.new();cover.texture=load('res://assets/covers/little-knights-cover-v1.png');cover.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;cover.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED;cover.size=screen.size;screen.add_child(cover)
 add_button('Start Game',Vector2(570,650),Vector2(300,60),func():show_setup(true),true)
 add_button('How to Play',Vector2(570,720),Vector2(300,60),func():show_guide(true))
 if not OS.has_feature('web'):add_button('Exit',Vector2(570,790),Vector2(300,60),func():g.exit_game())
 add_match_setup()
 add_controls_guide()
 g.paused=true
func add_button(title,pos,dimensions,action,primary=false):
 var b=Button.new();b.text=title;b.position=pos;b.size=dimensions;b.add_theme_font_size_override('font_size',24 if primary else 20);b.add_theme_color_override('font_color',Color('#fff0cd'));b.add_theme_stylebox_override('normal',g.style(Color('#38685d') if primary else Color('#302a20')));b.add_theme_stylebox_override('hover',g.style(Color('#518a77') if primary else Color('#5c4930')));b.pressed.connect(action);screen.add_child(b);menu_buttons.append(b);return b
func is_open():return screen.visible
func start():
 show_setup(false);screen.hide();g.paused=false

func add_controls_guide():
 var panel=PanelContainer.new();guide=panel;panel.position=Vector2(470,405);panel.custom_minimum_size=Vector2(500,420);panel.hide()
 var background=g.style(Color('#302a20',0.94));background.content_margin_left=18;background.content_margin_right=18;background.content_margin_top=12;background.content_margin_bottom=12
 panel.add_theme_stylebox_override('panel',background);screen.add_child(panel)
 var rows=VBoxContainer.new();rows.add_theme_constant_override('separation',9);panel.add_child(rows)
 var title=Label.new();title.text='HOW TO PLAY';title.add_theme_font_size_override('font_size',19);title.add_theme_color_override('font_color',Color('#fff0cd'));rows.add_child(title)
 for line in ['WASD / arrows    Move camera','Left-click / drag    Select · Shift: add','Right-click: order · Alt + right-click: ground','X + left-click    Attack-move','H    Stop movement AND automatic attacks','Z    Toggle idle auto repair (default ON)','F: army · .: worker · Q / E: train','Ctrl / Cmd + 1–9    Save group · 1–9: select','Space    Pause · Esc: cancel / deselect']:
  var label=Label.new();label.text=line;label.add_theme_font_size_override('font_size',15);label.add_theme_color_override('font_color',Color('#e2d7ba'));rows.add_child(label)

 var back=Button.new();back.text='Back';back.custom_minimum_size=Vector2(0,46);back.add_theme_font_size_override('font_size',20);back.add_theme_stylebox_override('normal',g.style(Color('#38685d')));back.add_theme_stylebox_override('hover',g.style(Color('#518a77')));back.pressed.connect(func():show_guide(false));rows.add_child(back)
func show_guide(visible):
 guide.visible=visible
 setup_panel.hide()
 for b in menu_buttons:b.visible=not visible
func _input(event):
 if is_open() and (guide.visible or setup_panel.visible) and event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE:
  show_guide(false);get_viewport().set_input_as_handled()

func add_match_setup():
 setup_panel=PanelContainer.new();setup_panel.position=Vector2(470,540);setup_panel.custom_minimum_size=Vector2(500,212)
 var background=g.style(Color('#302a20',0.96));background.content_margin_left=24;background.content_margin_right=24;background.content_margin_top=20;background.content_margin_bottom=20
 setup_panel.add_theme_stylebox_override('panel',background);screen.add_child(setup_panel);setup_panel.hide()
 var rows=VBoxContainer.new();rows.add_theme_constant_override('separation',18);setup_panel.add_child(rows)
 var title=Label.new();title.text='DIFFICULTY';title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;title.add_theme_font_size_override('font_size',20);title.add_theme_color_override('font_color',Color('#fff0cd'));rows.add_child(title)
 var choices=HBoxContainer.new();choices.add_theme_constant_override('separation',10);rows.add_child(choices)
 for key in ['easy','normal','hard']:
  var choice=key
  var b=setup_button(choice.capitalize(),func():g.difficulty=choice;start())
  b.size_flags_horizontal=Control.SIZE_EXPAND_FILL
  b.add_theme_stylebox_override('pressed',g.style(Color('#38685d')));choices.add_child(b);difficulty_choices[choice]=b
 rows.add_child(setup_button('Back',func():show_setup(false)))
func setup_button(title,action,primary=false):
 var b=Button.new();b.text=title;b.custom_minimum_size=Vector2(0,46);b.add_theme_font_size_override('font_size',20);b.add_theme_color_override('font_color',Color('#fff0cd'))
 b.add_theme_stylebox_override('normal',g.style(Color('#38685d') if primary else Color('#493923')));b.add_theme_stylebox_override('hover',g.style(Color('#518a77') if primary else Color('#705333')));b.pressed.connect(action);return b
func show_setup(visible):
 guide.hide();setup_panel.visible=visible
 for b in menu_buttons:b.visible=not visible
