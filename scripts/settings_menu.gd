extends CanvasLayer
var g
var shade:ColorRect
var volume_label:Label
var was_paused=false
var subtitle
var resume_button
var fullscreen_button
var restart_button
func _init(game):g=game;layer=100
func _ready():
 shade=ColorRect.new();shade.color=Color(0.05,0.07,0.06,0.65);shade.size=Vector2(1440,900);add_child(shade)
 var card=Panel.new();card.position=Vector2(480,220);card.size=Vector2(480,520);card.add_theme_stylebox_override('panel',g.style(Color('#292219')));shade.add_child(card)
 var title=text('SETTINGS',Vector2(530,248),28)
 title.size.x=380;title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 subtitle=text('Game paused',Vector2(530,290),16)
 subtitle.size.x=380;subtitle.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 volume_label=text('',Vector2(530,340),18)
 var slider=HSlider.new();slider.position=Vector2(530,378);slider.size=Vector2(380,28);slider.min_value=0;slider.max_value=100;slider.step=1;shade.add_child(slider)
 var config=ConfigFile.new();config.load('user://settings.cfg')
 slider.value=clampf(float(config.get_value('audio','volume',80)),0,100)
 set_volume(slider.value)
 slider.value_changed.connect(set_volume)
 fullscreen_button=add_button('Fullscreen',Vector2(530,420),toggle_fullscreen)
 resume_button=add_button('Resume',Vector2(530,484),func():close())
 restart_button=add_button('Restart',Vector2(530,548),func():close();g.reset())
 add_button('Main Menu' if OS.has_feature('web') else 'Exit',Vector2(530,612),func():g.exit_game())
 shade.hide()
func text(value,pos,font_size):
 var label=Label.new();label.text=value;label.position=pos;label.add_theme_font_size_override('font_size',font_size);label.add_theme_color_override('font_color',Color('#eadbb5'));shade.add_child(label);return label
func add_button(title,pos,action):
 var b=Button.new();b.text=title;b.position=pos;b.size=Vector2(380,48);b.add_theme_stylebox_override('normal',g.style(Color('#493923')));b.add_theme_stylebox_override('hover',g.style(Color('#705333')));b.pressed.connect(action);shade.add_child(b);return b
func set_volume(value):
 AudioServer.set_bus_volume_db(0,linear_to_db(maxf(value/100,0.0001)))
 AudioServer.set_bus_mute(0,value==0)
 volume_label.text='Volume  %d%%'%int(value)
 var config=ConfigFile.new();config.set_value('audio','volume',value);config.save('user://settings.cfg')
func is_open():return shade!=null and shade.visible
func open(from_title=false):
 if is_open():return
 subtitle.visible=not from_title
 resume_button.text='Back' if from_title else 'Resume'
 restart_button.visible=not from_title
 was_paused=g.paused;g.paused=true;shade.show()
func close():
 shade.hide();g.paused=was_paused
func _input(event):
 if is_open() and event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_ESCAPE,KEY_SPACE]:
  close();get_viewport().set_input_as_handled()

func toggle_fullscreen():
 var window=get_window()
 window.mode=Window.MODE_WINDOWED if window.mode in [Window.MODE_FULLSCREEN,Window.MODE_EXCLUSIVE_FULLSCREEN] else Window.MODE_FULLSCREEN
func _process(_dt):
 if fullscreen_button!=null and is_open():
  fullscreen_button.text='Windowed' if get_window().mode in [Window.MODE_FULLSCREEN,Window.MODE_EXCLUSIVE_FULLSCREEN] else 'Fullscreen'
