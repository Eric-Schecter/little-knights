extends Node
var g
var groups={}
var last_key=-1
var last_press=-1000
var panel:ScrollContainer
var grid:GridContainer
var cards=[]
var signature=[]
var replies=[]
var reply_clock=0.0
var voice:AudioStreamPlayer
var badges=[]
func _init(game):g=game
func _ready():
 voice=AudioStreamPlayer.new();add_child(voice);voice.volume_db=-9
 panel=ScrollContainer.new();panel.position=Vector2(265,750);panel.size=Vector2(350,142);g.hud.add_child(panel)
 grid=GridContainer.new();grid.columns=6;grid.add_theme_constant_override('h_separation',5);grid.add_theme_constant_override('v_separation',5);panel.add_child(grid)
 for i in range(9):
  var index=i+1
  var b=g.button(str(index),Vector2(858+i*42,20),Vector2(36,32),func():recall(index))
  b.add_theme_font_size_override('font_size',14);b.tooltip_text='Ctrl+%d: save · %d: select · double press: locate'%[index,index];badges.append(b)
func alive(u):return u.hp>0 and u.team==0 and g.contains_entity(g.units,u)
func reset():groups.clear();replies.clear();last_key=-1
func key(event):
 if not event is InputEventKey or not event.pressed or event.echo:return false
 if event.keycode<KEY_1 or event.keycode>KEY_9:return false
 var index=event.keycode-KEY_0
 if event.ctrl_pressed or event.meta_pressed:
  groups[index]=g.selected.filter(alive).duplicate();g.tell('Group %d · %d units'%[index,groups[index].size()])
 else:recall(index)
 return true
func recall(index):
 var members=groups.get(index,[]).filter(alive)
 groups[index]=members
 if members.is_empty():return
 g.selected=members.duplicate();g.refresh_commands()
 var now=Time.get_ticks_msec()
 if last_key==index and now-last_press<400:
  var center=Vector2.ZERO
  for u in members:center+=u.p
  g.cam=(center/members.size()-g.field_rect().get_center()).clamp(Vector2(0,-72),g.camera_limit())
 last_key=index;last_press=now
func selected_sound():
 replies.clear();reply_clock=0
 if g.paused:return
 var kinds=[]
 for u in g.selected:
  if alive(u) and not kinds.has(u.kind):kinds.append(u.kind)
 replies=kinds
 if kinds.is_empty() and not g.selected.is_empty():g.sound('select')
func _process(dt):
 for index in groups:groups[index]=groups[index].filter(alive)
 for i in range(badges.size()):
  badges[i].visible=not groups.get(i+1,[]).is_empty()
  if badges[i].visible:badges[i].tooltip_text='Group %d · %d units\nCtrl+%d save · double press to locate'%[i+1,groups[i+1].size(),i+1]
 reply_clock-=dt
 if not replies.is_empty() and reply_clock<=0:
  if not g.paused:
   var kind=replies.pop_front()
   var sample={'Warrior':'metalPot3','Archer':'handleSmallLeather','Spearman':'handleSmallLeather2','Cavalry':'handleCoins2','Catapult':'chop','Pawn':'handleSmallLeather'}.get(kind,'handleSmallLeather')
   voice.stream=load('res://assets/audio/kenney-rpg/'+sample+'.ogg')
   voice.pitch_scale={'Warrior':0.85,'Archer':1.12,'Spearman':0.95,'Cavalry':0.8,'Catapult':0.75,'Pawn':1.2}.get(kind,1.0)
   voice.play();reply_clock=maxf(0.25,voice.stream.get_length()/voice.pitch_scale+0.05)
  else:replies.clear()
 var members=g.selected.filter(alive)
 panel.visible=members.size()>1
 if not panel.visible:return
 var changed=members.size()!=signature.size()
 if not changed:
  for i in range(members.size()):
   if not is_same(members[i],signature[i]):changed=true;break
 if changed:
  signature=members.duplicate()
  for child in grid.get_children():grid.remove_child(child);child.queue_free()
  cards.clear()
  for unit in members:
   var u=unit
   var cell=VBoxContainer.new();grid.add_child(cell)
   var b=Button.new();b.custom_minimum_size=Vector2(50,50);b.icon=g.icon_hud.icons[u.kind];b.expand_icon=true;b.add_theme_constant_override('icon_max_width',42);b.add_theme_stylebox_override('normal',g.style(Color('#493923')));cell.add_child(b)
   b.pressed.connect(func():
    if Input.is_key_pressed(KEY_SHIFT):g.selected=g.selected.filter(func(v):return not is_same(v,u))
    else:g.selected=[u]
    g.refresh_commands())
   var bar=ProgressBar.new();bar.custom_minimum_size=Vector2(50,5);bar.show_percentage=false;g.icon_hud.style_bar(bar,Color('#79b59b'));cell.add_child(bar)
   cards.append({'unit':u,'button':b,'bar':bar})
 for c in cards:
  var u=c.unit;c.bar.value=100*u.hp/u.max
  c.bar.modulate=Color(1,0.45,0.4) if u.hp/u.max<0.3 else (Color(1,0.82,0.45) if u.hp/u.max<0.6 else Color.WHITE)
  c.button.tooltip_text='%s · %d / %d HP\n%s\nClick: select · Shift+click: remove'%[g.NAMES[u.kind],maxi(0,int(u.hp)),int(u.max),'Attacking' if u.target!=null else ('Moving' if u.moving else ('Working' if u.job!=null else 'Idle'))]
