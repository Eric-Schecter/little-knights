extends CanvasLayer
var g
var screen:Control
func _init(game):g=game;layer=90
func _ready():
 screen=Control.new();screen.size=Vector2(1440,900);screen.mouse_filter=Control.MOUSE_FILTER_STOP;add_child(screen)
 var cover=TextureRect.new();cover.texture=load('res://assets/covers/little-knights-cover-v1.png');cover.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;cover.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED;cover.size=screen.size;screen.add_child(cover)
 add_button('Start Game',Vector2(570,650),Vector2(300,60),start,true)
 if not OS.has_feature('web'):add_button('Exit',Vector2(570,724),Vector2(300,60),func():g.exit_game())
 g.paused=true
func add_button(title,pos,dimensions,action,primary=false):
 var b=Button.new();b.text=title;b.position=pos;b.size=dimensions;b.add_theme_font_size_override('font_size',24 if primary else 20);b.add_theme_color_override('font_color',Color('#fff0cd'));b.add_theme_stylebox_override('normal',g.style(Color('#38685d') if primary else Color('#302a20')));b.add_theme_stylebox_override('hover',g.style(Color('#518a77') if primary else Color('#5c4930')));b.pressed.connect(action);screen.add_child(b)
func is_open():return screen.visible
func start():
 screen.hide();g.paused=false
