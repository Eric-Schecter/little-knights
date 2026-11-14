extends RefCounted
var g
var totals=[]
var snapshot={}
var layer:CanvasLayer
var overlay:Control
var heading:Label
var subtitle:Label
var values=[]
var insight:Label
var replay:Button
var reopen:Button
const ROWS=[['gold','Gold'],['wood','Wood'],['army','Army trained'],['army_losses','Army lost']]
const ICONS=['gold','wood','Warrior','attack']
func _init(game):g=game
func reset():
 totals=[]
 for team in range(2):totals.append({'gold':0,'wood':0,'workers':0,'army':0,'worker_losses':0,'army_losses':0,'buildings':0})
 snapshot={}
 if overlay!=null:overlay.hide();reopen.hide()
func delivered(team,kind,amount):
 if snapshot.is_empty():totals[team][kind]+=amount
func trained(team,kind):
 if snapshot.is_empty():totals[team]['workers' if kind=='Pawn' else 'army']+=1
func lost(u):
 if not snapshot.is_empty() or u.get('loss_counted',false):return
 u['loss_counted']=true
 var key='buildings' if g.contains_entity(g.buildings,u) else ('worker_losses' if u.kind=='Pawn' else 'army_losses')
 totals[u.team][key]+=1
func label(parent,text,p,size,color=Color('#f4e7cc')):
 var l=Label.new();l.text=text;l.position=p;l.add_theme_font_size_override('font_size',size);l.add_theme_color_override('font_color',color);parent.add_child(l);return l
func rect(parent,box,color):
 var r=ColorRect.new();r.position=box.position;r.size=box.size;r.color=color;r.mouse_filter=Control.MOUSE_FILTER_IGNORE;parent.add_child(r)
func panel(parent,box,fill,border,width=3):
 var p=Panel.new();p.position=box.position;p.size=box.size;p.mouse_filter=Control.MOUSE_FILTER_IGNORE
 var style=StyleBoxFlat.new();style.bg_color=fill;style.border_color=border;style.set_border_width_all(width);style.set_corner_radius_all(16)
 style.shadow_color=Color(0.12,0.09,0.05,0.3);style.shadow_size=8 if width>0 else 0;style.shadow_offset=Vector2(0,6)
 p.add_theme_stylebox_override('panel',style);parent.add_child(p)
func picture(parent,key,p,size):
 var t=TextureRect.new();t.texture=g.icon_hud.icons[key];t.position=p;t.size=size;t.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;t.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;t.mouse_filter=Control.MOUSE_FILTER_IGNORE;parent.add_child(t);t.set_deferred('size',size)
func action(parent,text,p,size,callback):
 var b=Button.new();b.text=text;b.position=p;b.size=size;b.add_theme_font_size_override('font_size',20)
 for state in ['normal','hover','pressed','focus']:
  var style=StyleBoxFlat.new();style.bg_color=Color('#477e70') if state=='normal' else Color('#599584');style.border_color=Color('#d7bc7d');style.set_border_width_all(2);style.set_corner_radius_all(10)
  b.add_theme_stylebox_override(state,style)
 b.add_theme_color_override('font_color',Color('#fff2cf'));b.pressed.connect(callback);parent.add_child(b);return b
func build_ui():
 layer=CanvasLayer.new();layer.layer=20;g.add_child(layer)
 overlay=Control.new();overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);overlay.mouse_filter=Control.MOUSE_FILTER_STOP;layer.add_child(overlay)
 rect(overlay,Rect2(0,0,1440,900),Color(0.10,0.16,0.12,0.48))
 panel(overlay,Rect2(380,140,680,610),Color('#805a39'),Color('#b78d59'),4)
 panel(overlay,Rect2(396,156,648,578),Color('#efdfb7'),Color('#c6a575'),2)
 picture(overlay,'Castle',Vector2(418,176),Vector2(114,110))
 heading=label(overlay,'',Vector2(552,184),36,Color('#395e4e'))
 subtitle=label(overlay,'',Vector2(554,233),17,Color('#786244'))
 label(overlay,'YOU',Vector2(793,308),15,Color('#397f76'))
 label(overlay,'RIVAL',Vector2(933,308),15,Color('#b26750'))
 for i in range(ROWS.size()):
  var y=340+i*54
  panel(overlay,Rect2(428,y,584,46),Color('#e5d1a6') if i%2==0 else Color('#ead9b3'),Color('#ddc89e'),0)
  picture(overlay,ICONS[i],Vector2(441,y+5),Vector2(35,35))
  label(overlay,ROWS[i][1],Vector2(489,y+9),18,Color('#645034'))
  var pair=[]
  for x in [759,899]:
   var value=label(overlay,'0',Vector2(x,y+7),23,Color('#3e6557') if x==759 else Color('#a85f49'));value.size=Vector2(80,32);value.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT;pair.append(value)
  values.append(pair)
 insight=label(overlay,'',Vector2(440,571),18,Color('#786244'));insight.size=Vector2(560,40);insight.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 replay=action(overlay,'Play again',Vector2(428,641),Vector2(276,56),func():g.reset();g.refresh_commands())
 action(overlay,'Review battlefield',Vector2(722,641),Vector2(290,56),func():overlay.hide();reopen.show())
 reopen=action(layer,'Match results',Vector2(1180,84),Vector2(235,44),func():overlay.show();reopen.hide())
 overlay.hide();reopen.hide()
func finish(outcome,seconds,reason='Town Center destroyed'):
 if not snapshot.is_empty():return
 snapshot={'outcome':outcome,'seconds':seconds,'teams':totals.duplicate(true)}
 if g.supply!=null and g.supply.enabled and g.supply.camps_enabled:
  snapshot['supply_income']=g.supply.income.duplicate()
 snapshot['reason']=reason
 if overlay==null:return
 heading.text={'VICTORY':'VICTORY','DEFEAT':'DEFEAT','DRAW':'DRAW'}.get(outcome,outcome)
 heading.add_theme_color_override('font_color',Color('#397b68') if outcome=='VICTORY' else Color('#ad6651'))
 var duration=int(seconds)
 subtitle.text='%02d:%02d  /  %s'%[duration/60,duration%60,reason]
 for i in range(ROWS.size()):
  for team in range(2):values[i][team].text=str(snapshot.teams[team][ROWS[i][0]])
 insight.text='Workers lost: %d'%snapshot.teams[0].worker_losses
 if g.supply!=null and g.supply.enabled and g.supply.camps_enabled:
  insight.text='Camp income   +%d gold / +%d wood'%[snapshot.supply_income[0].x,snapshot.supply_income[0].y]
 overlay.show();reopen.hide();replay.grab_focus()
