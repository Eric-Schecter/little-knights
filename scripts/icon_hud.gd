extends RefCounted
var g
var icons={}
var values=[]
var portrait
var count
var health
var status
var progress
var construction_text
var attributes={}
var hp_text
var mana_text
var mana_bar
var mana_icon
var unit_name
func _init(game):
 g=game
 var shapes={
 'settings':'<circle cx="32" cy="32" r="16"/><circle cx="32" cy="32" r="6"/><path d="M32 8v8M32 48v8M8 32h8M48 32h8M15 15l6 6M43 43l6 6M15 49l6-6M43 21l6-6"/>',
 'armor':'<path fill="#7ba49b" d="M12 12l20-5 20 5v23c-2 12-13 20-20 24C20 53 12 45 12 35z"/><path d="M32 10v43"/>',
 'range':'<circle cx="32" cy="32" r="22"/><circle cx="32" cy="32" r="11"/><path d="M32 5v13M32 46v13M5 32h13M46 32h13"/>',
 'mana':'<path fill="#749bbd" d="M32 7C26 19 14 29 14 40a18 18 0 0 0 36 0C50 29 38 19 32 7z"/>',
 'gold':'<path fill="#e9ba56" d="M8 40l8-23h28l12 23-10 9H18z"/><path d="M16 17l9 22h31M25 39l-7 10"/>',
 'wood':'<path fill="#a6784b" d="M12 43L39 13l15 13-28 29z"/><ellipse fill="#e2bb7d" cx="19" cy="48" rx="10" ry="8"/><path d="M29 29l14 12M36 20l11 10"/>',
 'population':'<path fill="#7eb4a0" d="M11 30L32 11l21 19v24H11z"/><path d="M27 54V35h12v19"/>',
 'clock':'<circle cx="32" cy="32" r="22"/><path d="M32 16v17l12 7"/>',
 'attack':'<path fill="#bed5d0" d="M15 49L45 12l8-2-1 10-30 36z"/><path d="M14 36l16 14M10 54l8-10"/>',
 'stop':'<path fill="#b97c64" d="M22 10h20l14 14v18L42 56H22L8 42V24z"/><path d="M22 32h20"/>',
 'flag':'<path d="M17 56V8"/><path fill="#78b7a4" d="M18 10h32l-9 12 9 12H18"/>',
 'help':'<circle cx="32" cy="32" r="23"/><path d="M24 24c0-12 20-12 18 0-1 7-10 6-10 15M32 46v2"/>',
 'pause':'<path stroke-width="9" d="M23 16v32M41 16v32"/>',
 'restart':'<path d="M15 25a21 21 0 1 1 0 20M15 10v17h17"/>',
 'build':'<path fill="#bb9970" d="M13 18l10-9 29 24-10 11z"/><path stroke-width="8" d="M31 31L12 54"/>'}
 for key in shapes:
  var image=Image.new()
  image.load_svg_from_string('<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64"><g stroke="#eadbb5" stroke-width="3" stroke-linejoin="round" stroke-linecap="round" fill="none">'+shapes[key]+'</g></svg>')
  icons[key]=ImageTexture.create_from_image(image)
 for kind in g.NAMES:
  var cell=g.art.frames['Blue_'+kind][0]
  var atlas=AtlasTexture.new();atlas.atlas=cell.texture;atlas.region=cell.bounds;icons[kind]=atlas
 for branch in ['arrow','cannon']:
  var cell=g.art.frames['Blue_Tower_'+branch][0]
  var atlas=AtlasTexture.new();atlas.atlas=cell.texture;atlas.region=Rect2(Vector2(cell.bounds.position)+Vector2(0,cell.bounds.size.y*0.18),Vector2(cell.bounds.size.x,cell.bounds.size.y*0.48));icons['Tower_'+branch]=atlas
func picture(key,pos,size):
 var t=TextureRect.new();t.texture=icons[key];t.position=pos;t.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;t.size=size;t.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;t.mouse_filter=Control.MOUSE_FILTER_IGNORE;g.hud.add_child(t);t.set_deferred("size",size);return t
func decorate(b,key,hint):
 b.text='';b.icon_alignment=HORIZONTAL_ALIGNMENT_CENTER;b.icon=icons[key];b.expand_icon=true;b.add_theme_constant_override('icon_max_width',48);b.tooltip_text=hint
func command_key(text):
 text=text.split("\n")[0]
 for pair in [['Auto repair','build'],['Mining Camp','Depot'],['Spearman','Spearman'],['Catapult','Catapult'],['Blacksmith','Smith'],['Siege Workshop','Workshop'],['Armor','armor'],['Crossbow','Archer'],['Swordsman','Warrior'],['Knight','Cavalry'],['Worker','Pawn'],['worker','Pawn'],['House','House1'],['Barracks','Barracks'],['Arrow Tower','Tower'],['Watchtower','Tower'],['army','Warrior'],['Attack','attack'],['Stop','stop']]:
  if pair[0] in text:return pair[1]
 return 'build'
func style_bar(bar,color):
 var bg=StyleBoxFlat.new();bg.bg_color=Color('#3c382d');bg.set_corner_radius_all(4)
 var fill=StyleBoxFlat.new();fill.bg_color=color;fill.set_corner_radius_all(4)
 bar.add_theme_stylebox_override('background',bg);bar.add_theme_stylebox_override('fill',fill)
func build():
 g.stats.hide();g.details.hide();g.production_info.hide();g.message.hide()
 for i in range(4):
  var key=['gold','wood','population','clock'][i]
  var x=[28,220,412,684][i]
  picture(key,Vector2(x,16),Vector2(40,40))
  var label=g.label_at('',Vector2(x+50,23),22);label.tooltip_text=['Gold','Wood','Population / capacity','Match time'][i];label.mouse_filter=Control.MOUSE_FILTER_STOP;values.append(label)
 portrait=picture('flag',Vector2(265,750),Vector2(112,112))
 count=g.label_at('',Vector2(550,750),19)
 unit_name=g.label_at('',Vector2(388,750),19)
 hp_text=g.label_at('',Vector2(388,777),16)
 mana_text=g.label_at('',Vector2(418,831),15)
 mana_icon=picture('mana',Vector2(388,827),Vector2(22,22))
 mana_bar=ProgressBar.new();mana_bar.position=Vector2(388,854);mana_bar.show_percentage=false;style_bar(mana_bar,Color('#749bbd'));g.hud.add_child(mana_bar);mana_bar.size=Vector2(180,7)
 for i in range(4):
  var key=['attack','armor','range','clock'][i]
  var pos=Vector2(1150+(i%2)*140,750+int(i/2)*66)
  var icon=picture(key,pos,Vector2(35,35));icon.mouse_filter=Control.MOUSE_FILTER_STOP
  var value=g.label_at('',pos+Vector2(44,5),21);value.mouse_filter=Control.MOUSE_FILTER_STOP
  attributes[key]={'icon':icon,'value':value}
 health=ProgressBar.new();health.position=Vector2(388,800);health.size=Vector2(200,12);health.show_percentage=false;style_bar(health,Color('#79b59b'));g.hud.add_child(health);health.size=Vector2(200,12)
 var help=g.button('',Vector2(1378,862),Vector2(38,30),func():g.tell('LMB: select · RMB: order · Arrow keys: camera · Space: pause'))
 decorate(help,'help','LMB: select / drag\nRMB: move, gather, attack\nArrow keys: camera · Space: pause\nF: army · .: worker · A + LMB: attack move · H: stop movement and attacks')
 status=g.button('',Vector2(590,850),Vector2(38,36),func():pass);decorate(status,'help','')
 progress=ProgressBar.new();progress.position=Vector2(650,881);progress.size=Vector2(300,6);progress.show_percentage=false;style_bar(progress,Color('#d9b96c'));g.hud.add_child(progress);progress.size=Vector2(300,6)
 construction_text=g.label_at('',Vector2(650,851),17)
 construction_text.hide()
func update():
 for button in g.commands.get_children():
  if button.has_meta('auto_repair_button'):
   var active=g.selected.any(func(u):return u.get('auto_repair',false))
   button.modulate=Color('#82d9ad') if active else Color.WHITE
   button.tooltip_text=button.get_meta('base_hint')+('\nEnabled' if active else '\nDisabled')
 update_training_buttons()
 values[0].text=str(g.gold);values[1].text=str(g.wood);values[2].text='%d / %d'%[g.population(),g.capacity()];values[3].text='%02d:%02d'%[int(g.time)/60,int(g.time)%60]
 values[2].modulate=Color('#eea079') if g.population()>=g.capacity() else Color.WHITE
 var e=null if g.selected.is_empty() else g.selected[0]
 portrait.texture=icons['flag' if e==null else ('Tower_'+e.tower_branch if e.kind=='Tower' and e.get('tower_branch','')!='' else e.kind)]
 count.text='' if e==null or (g.contains_entity(g.buildings,e) and g.selected.size()==1) else '× '+str(g.selected.size())
 health.visible=e!=null
 hp_text.visible=e!=null;mana_text.visible=e!=null;mana_bar.visible=e!=null;mana_icon.visible=e!=null
 unit_name.text='' if e==null else g.NAMES[e.kind]
 if e!=null and e.kind=='Tower' and g.tower_upgrades.branch(e)!='':unit_name.text=g.tower_upgrades.NAMES[g.tower_upgrades.branch(e)]+' '+str(g.tower_upgrades.level(e))
 if e!=null:
  hp_text.text='%d / %d'%[max(0,e.hp),e.max]
  mana_text.text='—';mana_text.tooltip_text='No mana or mana-consuming abilities for this unit.'
  mana_bar.value=0;mana_bar.tooltip_text=mana_text.tooltip_text
 var armed=e!=null and e.kind in ['Pawn','Warrior','Archer','Tower','Spearman','Catapult','Cavalry']
 var data={
  'attack':['—' if not armed else str(int(g.base_attack(e))),'Base hit including blacksmith upgrade. Spearman: +18 vs cavalry, +9 vs swordsmen. Catapult: 90 + upgrade vs buildings; area 55px. Crossbow: half damage at close range.'],
  'armor':['—' if e==null else '%d / %d'%[g.armor_value(e),g.armor_value(e)+(6 if e.kind=='Warrior' else 0)],'Damage blocked: melee / arrows. Blacksmith: +2 each armor level. Swordsmen block 6 more from arrows. Mounted knights have 2 base armor.'],
  'range':['—' if not armed else str(int(g.attack_range(e))),'Attack range in world pixels, measured from target contact boundary.'],
  'clock':['—' if not armed else ('%.1f s'%g.attack_interval(e)),'Attack interval. Movement and lost targets can delay attacks.']}
 for key in attributes:
  var item=attributes[key];item.icon.visible=e!=null;item.value.visible=e!=null
  item.value.text=data[key][0];item.value.tooltip_text=data[key][1];item.icon.tooltip_text=data[key][1]
 if e!=null:health.value=e.hp/e.max*100;health.tooltip_text=g.details.text
 portrait.mouse_filter=Control.MOUSE_FILTER_STOP;portrait.tooltip_text=g.details.text
 status.visible=g.note_timer>0;status.tooltip_text=g.note
 # Failed actions still need immediate explanation, rather than an ambiguous icon.
 var warning=false
 for word in ['Need ','full','blocked','Cannot','Select soldiers first','Complete the building','Population']:
  if word in g.note:warning=true
 g.message.visible=g.note_timer>0 and warning
 progress.visible=e!=null and not e.queue.is_empty()
 if progress.visible:progress.value=e.train/g.economy.duration(e.queue[0])*100;progress.tooltip_text=g.production_info.text

 if e!=null and e.research!='':
  progress.visible=true;progress.value=e.research_time/g.technology.duration(e.team,e.research)*100
  progress.tooltip_text=e.research.capitalize()+' research · level '+str(g.technology.levels[e.team][e.research]+1)

 var constructing=e!=null and e.progress<1 and g.contains_entity(g.buildings,e)
 construction_text.visible=constructing
 if constructing:
  construction_text.text='Construction · %d%%'%int(e.progress*100)
  progress.visible=true;progress.value=e.progress*100
  progress.tooltip_text='Assign workers with right-click to continue construction.'

 if e!=null and e.get('tower_pending','')!='':
  construction_text.visible=true;construction_text.text='Upgrade · %d%%'%int(e.tower_clock/g.tower_upgrades.duration(e)*100)
  progress.visible=true;progress.value=e.tower_clock/g.tower_upgrades.duration(e)*100
  progress.tooltip_text='Tower cannot fire while upgrading.'

 # Multi-selection uses individual portraits and health bars in the left pane.
 var multiple=g.selected.filter(func(u):return g.contains_entity(g.units,u) and u.hp>0).size()>1
 for widget in [portrait,count,unit_name,hp_text,mana_text,mana_bar,mana_icon,health,status]:
  if multiple:widget.hide()
 if not multiple:portrait.show();count.show();unit_name.show()

func update_training_buttons():
 for button in g.commands.get_children():
  if not button.has_meta('train_kind') or button.is_queued_for_deletion():continue
  var reasons=g.economy.training_requirements(button.get_meta('train_kind'),button.get_meta('train_building'))
  button.disabled=not reasons.is_empty()
  button.self_modulate=Color(0.48,0.48,0.48) if button.disabled else Color.WHITE
  button.tooltip_text=button.get_meta('base_hint')+('\nMissing requirements:\n'+'\n'.join(reasons) if button.disabled else '\nReady to train')
