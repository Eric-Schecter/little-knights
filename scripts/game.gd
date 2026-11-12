extends Node2D
var economy
var responsive_layout
var repairs
var random_map
var random_map_enabled=false
var map_seed=0
var map_style="river"
var map_variant=-1
var requested_map_seed=-1
var technology
var icon_hud
var sfx
var supply
var art
var woodland_video=false
var woodland_demo
var blue_orders_video=false
var blue_orders_demo
var polish_video=false
var polish_demo
var fog
var arrival_video=false
var arrival_demo
var defense_video=false
var defense_demo
var match_results
var results_video=false
var results_demo
var blocking
var blocking_video=false
var blocking_demo
var opponent
var ai_enabled=true
var enemy_money=Vector2i(300,300)
var enemy_gathered=0
var enemy_trained=0
var match_substep=false
var match_video=false
var match_driver
var tower_upgrades
var match_finish_wait=0.0
var roles_video=false
var roles_demo
var map_video=false
var map_phase=0
var map_squad=[]
var ai_video=false
var economy_video=false
var economy_phase=0
var economy_house
var economy_barracks
var preview_position=Vector2.ZERO
var preview_override=false
var queue_row:HBoxContainer
var queue_signature=""
var production_info:Label
var CROSSINGS=[Vector2(622,754),Vector2(222,354)]
var WORLD=Vector2(2400,1400)
const NAMES={"Pawn":"Worker","Warrior":"Swordsman","Cavalry":"Knight","Archer":"Crossbowman","Castle":"Town Center","Barracks":"Barracks","House1":"House","Tower":"Arrow Tower","Spearman":"Spearman","Catapult":"Catapult","Smith":"Blacksmith","Workshop":"Siege Workshop","Depot":"Mining Camp"}
var combat_events:Array=[]
var combat_video=false
var combat_phase=0
var formations:Array=[]
var formation_video=false
var formation_phase=0
var nav=AStarGrid2D.new()
var nav_dirty=true
var attack_cursor=false
var review=false
var review_step=0
var units:Array=[]
var buildings:Array=[]
var resources:Array=[]
var shots:Array=[]
var effects:Array=[]
var selected:Array=[]
var tex={}
var gold=300
var wood=300
var camera_controls
var cam=Vector2(0,160)
var time=0.0
var raid=60.0
var wave=0
var drag=false
var drag_start=Vector2.ZERO
var build_mode=""
var note="Select workers, then right-click gold or trees to gather."
var note_timer=12.0
var settings_menu
var start_menu
var interface_audio
var selection_tools
var paused=false
var outcome=""
var hud:CanvasLayer
var stats:Label
var details:Label
var message:Label
var commands:GridContainer
var result:Label
var demo=false
var capture_done=false
var demo_started=false
var sound_cool=0.0
var kills=0
var gathered=0
var trained=0
func _ready():
 repairs=preload("res://scripts/worker_repair.gd").new(self)
 get_window().content_scale_aspect=Window.CONTENT_SCALE_ASPECT_EXPAND
 camera_controls=preload("res://scripts/camera_controls.gd").new(self)
 add_child(camera_controls)
 var args=OS.get_cmdline_user_args()
 var large=not ('--classic' in args or '--self-test' in args or '--fixed-map' in args or Array(args).any(func(a):return a.ends_with('-video') and a!='--supply-video'))
 if large:WORLD=Vector2(3200,2200)
 web_loading_stage("Loading sound effects…")
 sfx=preload("res://scripts/game_audio.gd").new(self)
 fog=preload("res://scripts/fog.gd").new(self)
 match_results=preload("res://scripts/match_results.gd").new(self)
 blocking=preload("res://scripts/unit_blocking.gd").new(self)
 economy=preload("res://scripts/economy.gd").new(self)
 tower_upgrades=preload('res://scripts/tower_upgrades.gd').new(self)
 technology=preload("res://scripts/technology.gd").new(self)
 texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
 web_loading_stage("Preparing sprites and terrain…")
 art=preload('res://scripts/woodland_art.gd').new(self)
 supply=preload('res://scripts/supply.gd').new(self)
 supply.enabled=not ('--classic' in args or '--self-test' in args or Array(args).any(func(a):return a.ends_with('-video') and a!='--supply-video'))
 random_map=preload('res://scripts/random_map.gd').new(self)
 random_map_enabled=supply.enabled and not '--fixed-map' in args
 for arg in args:
  if arg.begins_with('--map-seed='):requested_map_seed=int(arg.substr(11))
 opponent=preload("res://scripts/opponent.gd").new(self)
 web_loading_stage("Building map and interface…")
 reset()
 make_hud()
 match_results.build_ui()
 supply.build_ui()
 review="--stage1-video" in OS.get_cmdline_user_args()
 if review:setup_review()
 formation_video="--formation-video" in OS.get_cmdline_user_args()
 if formation_video:setup_formation_video()
 combat_video="--combat-video" in OS.get_cmdline_user_args()
 if combat_video:setup_combat_video()
 economy_video="--economy-video" in OS.get_cmdline_user_args()
 if economy_video:setup_economy_video()
 ai_video='--ai-video' in OS.get_cmdline_user_args()
 if ai_video:cam=Vector2(1000,300)
 map_video='--map-video' in OS.get_cmdline_user_args()
 if map_video:setup_map_video()
 roles_video='--roles-video' in OS.get_cmdline_user_args()
 if roles_video:
  ai_enabled=false
  roles_demo=preload('res://scripts/roles_demo.gd').new(self)
  roles_demo.setup()
 match_video='--match-video' in OS.get_cmdline_user_args() or '--supply-video' in OS.get_cmdline_user_args()
 if match_video:match_driver=preload('res://scripts/match_driver.gd').new(self)
 blocking_video='--blocking-video' in OS.get_cmdline_user_args()
 if blocking_video:
  blocking_demo=preload('res://scripts/blocking_demo.gd').new(self)
  blocking_demo.setup()
 results_video='--results-video' in OS.get_cmdline_user_args()
 if results_video:
  results_demo=preload('res://scripts/results_demo.gd').new(self)
  results_demo.setup()
 defense_video='--defense-video' in OS.get_cmdline_user_args()
 if defense_video:
  defense_demo=preload('res://scripts/defense_demo.gd').new(self)
  defense_demo.setup()
 woodland_video='--woodland-video' in OS.get_cmdline_user_args()
 if woodland_video:
  woodland_demo=preload('res://scripts/woodland_demo.gd').new(self);woodland_demo.setup()
 blue_orders_video='--blue-orders-video' in OS.get_cmdline_user_args()
 if blue_orders_video:
  blue_orders_demo=preload('res://scripts/blue_orders_demo.gd').new(self);blue_orders_demo.setup()
 polish_video='--polish-video' in OS.get_cmdline_user_args()
 if polish_video:
  polish_demo=preload('res://scripts/polish_demo.gd').new(self);polish_demo.setup()
 arrival_video='--arrival-video' in OS.get_cmdline_user_args()
 if arrival_video:
  arrival_demo=preload('res://scripts/arrival_demo.gd').new(self)
  arrival_demo.setup()
 demo='--demo' in OS.get_cmdline_user_args()
 if '--start-paused' in OS.get_cmdline_user_args():paused=true
 if '--self-test' in OS.get_cmdline_user_args():call_deferred('self_test')
 var skip_title='--skip-title' in OS.get_cmdline_user_args() or '--script' in OS.get_cmdline_args() or Array(OS.get_cmdline_user_args()).any(func(a):return a.ends_with('-video') or a=='--self-test' or a=='--demo')
 if not skip_title:
  start_menu=preload('res://scripts/start_menu.gd').new(self);add_child(start_menu)
 selection_tools=preload('res://scripts/selection_tools.gd').new(self);add_child(selection_tools)
 interface_audio=preload('res://scripts/interface_audio.gd').new(self);add_child(interface_audio)
 responsive_layout=preload('res://scripts/responsive_layout.gd').new(self);add_child(responsive_layout)
 if OS.has_feature('web'):call_deferred('notify_web_ready')
func contains_entity(group,value):
 return group.any(func(item):return is_same(item,value))
func entity(kind,p,team=0):
 var hp={"Pawn":70,"Warrior":145,"Archer":85,"Castle":1800,"Barracks":650,"House1":350,"Tower":700,"Cavalry":190,"Spearman":110,"Catapult":160,"Smith":550,"Workshop":750,"Depot":450}.get(kind,100)
 return {"research":"","research_time":0.0,"carry_kind":"gold","returning":false,"work_state":"Idle","work_clock":0.0,"windup":0.0,"swing_time":-1.0,"pending":null,"slot_velocity":Vector2.ZERO,"motion_hold":0.0,"stride":fposmod(p.x*0.013+p.y*0.017,1.0),"step_distance":0.0,"hurt_time":0.0,"formation":-1,"mode":"guard","path":PackedVector2Array(),"path_goal":Vector2(-999,-999),"kind":kind,"p":p,"team":team,"hp":float(hp),"max":float(hp),"goal":p,"target":null,"job":null,"carry":0,"tick":0.0,"cool":0.0,"moving":false,"face":1.0,"progress":1.0,"queue":[],"train":0.0,"rally":p+Vector2(110,100)}
func reset():
 if selection_tools!=null:selection_tools.reset()
 if technology!=null:technology.reset()
 if sfx!=null:sfx.reset()
 if match_results!=null:match_results.reset()
 if blocking!=null:blocking.contacts=0
 enemy_money=Vector2i(300,300);enemy_gathered=0;enemy_trained=0;match_finish_wait=0
 if opponent!=null:opponent.reset()
 combat_events.clear()
 formations.clear()
 units.clear();buildings.clear();resources.clear();selected.clear();shots.clear();effects.clear()
 nav_dirty=true;queue_signature="";build_mode="";attack_cursor=false;gold=300;wood=300;time=0;raid=60;wave=0;kills=0;gathered=0;trained=0;outcome='';paused=false;cam=Vector2(0,160)
 buildings.append(entity('Castle',Vector2(360,530)))
 buildings.append(entity('Castle',Vector2(2050,730),1))
 for i in range(4):units.append(entity('Pawn',Vector2(280+i*48,650)))
 for i in range(4):units.append(entity('Pawn',Vector2(1960+i*48,850),1))
 for p in [Vector2(210,780),Vector2(2190,1000)]:resources.append({"kind":"gold","p":p,"amount":900,"zone":"HOME"})
 for p in [Vector2(930,410),Vector2(1470,410),Vector2(930,1050),Vector2(1470,1050)]:resources.append({"kind":"gold","p":p,"amount":2600,"zone":"RICH"})
 var rng=RandomNumberGenerator.new();rng.seed=39
 for i in range(70):
  var p=Vector2(rng.randf_range(100,2300),rng.randf_range(130,1250))
  if resources.any(func(r):return r.p.distance_to(p)<115):continue
  if p.distance_to(Vector2(360,530))<220 or p.distance_to(Vector2(2050,730))<240 or abs(p.x-WORLD.x/2)<160:continue
  resources.append({"kind":"wood","p":p,"amount":350})
 for i in range(4):resources.append({"kind":"wood","p":Vector2(180+i*65,350),"amount":350})
 if random_map_enabled:
  var map_rng=RandomNumberGenerator.new();map_rng.randomize()
  map_seed=requested_map_seed if requested_map_seed>=0 else int(map_rng.randi() & 0x7fffffff)
  if requested_map_seed<0 and map_seed%3==map_variant:map_seed+=1
  random_map.apply(map_seed)
  print('RANDOM MAP seed=',map_seed,' crossings=',CROSSINGS)
 else:map_style='river';CROSSINGS=[Vector2(622,754),Vector2(222,354)]
 if supply!=null:supply.reset()
 if fog!=null:fog.reset()
 if commands!=null:refresh_commands()
func capacity(team=0):
 var cap=5
 for b in buildings:
  if b.team==team and b.hp>0 and b.kind=='House1' and b.progress>=1:cap+=5
 return cap
func population_cost(kind):return 2 if kind=="Cavalry" else 1
func population(team=0):
 var n=0
 for u in units:
  if u.team==team and u.hp>0:n+=population_cost(u.kind)
 for b in buildings:
  if b.team==team and b.hp>0:
   for kind in b.queue:n+=population_cost(kind)
 return n
func tell(s):note=s;note_timer=5
func sound(n):
 if sfx!=null:sfx.play(n)
func exit_game():
 if OS.has_feature('web'):
  if settings_menu.is_open():settings_menu.close()
  if start_menu==null:
   start_menu=preload('res://scripts/start_menu.gd').new(self);add_child(start_menu)
  reset();start_menu.screen.show();paused=true
  if responsive_layout!=null:responsive_layout.apply()
  return
 await get_tree().create_timer(0.15).timeout
 get_tree().quit()
func toggle_pause():
 if outcome=='':paused=!paused
func make_hud():
 hud=CanvasLayer.new();add_child(hud)
 icon_hud=preload("res://scripts/icon_hud.gd").new(self)
 panel(Rect2(0,0,1440,72),Color('#241d18'))
 stats=label_at('',Vector2(340,22),23)
 var settings_button=button('',Vector2(1364,14),Vector2(52,44),func():settings_menu.open())
 icon_hud.decorate(settings_button,'settings','Settings · pause, volume, restart and exit')
 settings_menu=preload('res://scripts/settings_menu.gd').new(self);add_child(settings_menu)
 panel(Rect2(240,732,1200,168),Color('#292219'))
 details=label_at('',Vector2(254,750),20)
 message=label_at('',Vector2(254,704),18,Color('#fff2c3'))
 message.add_theme_color_override('font_shadow_color',Color('#241d18'))
 message.add_theme_constant_override('shadow_offset_x',1);message.add_theme_constant_override('shadow_offset_y',2)
 commands=GridContainer.new();commands.columns=6;commands.position=Vector2(650,758);commands.add_theme_constant_override('h_separation',9);commands.add_theme_constant_override('v_separation',4);hud.add_child(commands)

 queue_row=HBoxContainer.new();queue_row.position=Vector2(650,825);queue_row.add_theme_constant_override('separation',6);hud.add_child(queue_row)
 production_info=label_at('',Vector2(650,806),13,Color('#e9d9ab'))
 result=label_at('',Vector2(420,310),38,Color('#ffe6a1'))
 icon_hud.build()
 refresh_commands()
func panel(r,c):
 var p=ColorRect.new();p.position=r.position;p.size=r.size;p.color=c;hud.add_child(p)
func label_at(s,p,size=18,color=Color('#f4e7cc')):
 var l=Label.new();l.text=s;l.position=p;l.add_theme_font_size_override('font_size',size);l.add_theme_color_override('font_color',color);hud.add_child(l);return l
func style(c):
 var s=StyleBoxFlat.new();s.bg_color=c;s.border_color=Color('#94754a');s.set_border_width_all(2);s.set_corner_radius_all(7);s.content_margin_left=12;s.content_margin_right=12;return s
func button(s,p,sz,action):
 var b=Button.new();b.text=s;b.position=p;b.size=sz;b.add_theme_stylebox_override('normal',style(Color('#493923')));b.add_theme_stylebox_override('hover',style(Color('#705333')));b.add_theme_font_size_override('font_size',17);b.pressed.connect(action);hud.add_child(b);return b
func cmd(s,action):
 var b=Button.new();b.text=s;b.custom_minimum_size=Vector2(72,64);b.add_theme_stylebox_override('normal',style(Color('#493923')));b.add_theme_stylebox_override('hover',style(Color('#705333')));b.pressed.connect(action);commands.add_child(b)
 icon_hud.decorate(b,icon_hud.command_key(s),s)
 var title=s.split('\n')[0]
 if not selected.is_empty() and selected[0].kind in ['Castle','Barracks','Workshop']:
  var key=icon_hud.command_key(s)
  if key in ['Pawn','Warrior','Archer','Spearman','Cavalry','Catapult']:
   b.set_meta('train_kind',key);b.set_meta('train_building',selected[0])
 if 'Knight' in title:b.tooltip_text+='\n'+role_text('Cavalry')
 elif 'Swordsman' in s:b.tooltip_text+='\n'+role_text('Warrior')
 elif 'Crossbow' in s:b.tooltip_text+='\n'+role_text('Archer')
 elif 'Watchtower' in s:b.tooltip_text+='\n'+role_text('Tower')
 b.set_meta('base_hint',b.tooltip_text)
 icon_hud.update_training_buttons()
 return b
func refresh_commands():
 if selection_tools!=null:selection_tools.selected_sound()
 for c in commands.get_children():c.queue_free()
 if selected.is_empty():
  cmd('Select army\n[F]',select_army);cmd('Find worker\n[.]',select_worker);return
 var e=selected[0]
 if e.progress<1:
  cmd('Under construction',func():tell('Assign workers with right-click to complete construction.'));return
 if e.kind=='Castle':cmd('Worker [Q]\n50 gold · 5s',func():train('Pawn',e))
 elif e.kind=='Barracks':
  cmd('Swordsman [Q]\n80 gold · 8s',func():train('Warrior',e));cmd('Crossbow [E]\n60 gold 30 wood · 8s',func():train('Archer',e));cmd('Spearman\n55 gold 20 wood · 7s',func():train('Spearman',e));cmd('Knight\n125 gold 40 wood · 12s · 2 population\nRequires completed Blacksmith',func():train('Cavalry',e))
 elif e.kind=='Tower':tower_upgrades.commands(e)
 elif e.kind=='Workshop':cmd('Catapult\n140 gold 100 wood · 16s',func():train('Catapult',e))
 elif e.kind=='Smith':
  for upgrade in ['attack','armor']:
   var key=upgrade;var level=technology.levels[e.team][key];var price=technology.price(e.team,key)
   var research_button=cmd('%s +%d / 2\n%d gold %d wood · %.0fs'%[key.capitalize(),level,price.x,price.y,technology.duration(e.team,key)],func():technology.research(e,key))
   var badge=Label.new();badge.text='%d/2'%level;badge.position=Vector2(39,43);badge.add_theme_font_size_override('font_size',12);badge.mouse_filter=Control.MOUSE_FILTER_IGNORE;research_button.add_child(badge)
   research_button.disabled=level>=2 or e.research!=''
   research_button.tooltip_text+='\nAll existing and future military units. Research is lost if this building is destroyed.'
 elif e.kind=='Pawn':
  var repair_button=cmd('Auto repair [Z]\nToggle nearby friendly building repairs (450 range).\n20 HP/s; 1 wood per 10 HP. Manual orders or H cancel.',func():repairs.toggle())
  repair_button.set_meta('auto_repair_button',true)
  for k in ['House1','Barracks','Tower','Smith','Workshop','Depot']:
   var kind=k
   cmd('%s\n%d wood'%[NAMES[k],cost(k)],func():build_mode=kind;tell('Left-click to place '+NAMES[kind]+'. Right-click cancels.'))
func cost(k):return {"House1":80,"Barracks":140,"Tower":180,"Smith":120,"Workshop":200,"Depot":100}.get(k,0)
func train(k,b):return economy.train(k,b)
func select_army():
 selected=units.filter(func(u):return u.team==0 and u.kind!='Pawn');refresh_commands()
func select_worker():
 selected=units.filter(func(u):return u.team==0 and u.kind=='Pawn' and u.job==null).slice(0,1)
 if selected.is_empty():selected=units.filter(func(u):return u.team==0 and u.kind=='Pawn').slice(0,1)
 if not selected.is_empty():cam=selected[0].p-field_rect().get_center()
 refresh_commands()
func attack_base():
 var b=buildings.filter(func(v):return v.team==1 and v.kind=='Castle' and fog.sees(0,v.p))
 if not b.is_empty():order(b[0].p,b[0])
func world_mouse():return get_global_mouse_position()+cam
func _unhandled_input(e):
 if start_menu!=null and start_menu.is_open():return
 if settings_menu!=null and settings_menu.is_open():return
 if outcome!='':return
 if selection_tools!=null and selection_tools.key(e):return
 if e is InputEventKey and e.pressed and not e.echo:
  match e.keycode:
   KEY_SPACE:paused=!paused
   KEY_F:select_army()
   KEY_T:
    if supply.enabled:supply.order_to(0)
   KEY_Y:
    if supply.enabled:supply.order_to(1)
   KEY_PERIOD:select_worker()
   KEY_R:attack_base()
   KEY_A:attack_cursor=true;tell('Attack move: left-click destination. Escape cancels.')
   KEY_H:attack_cursor=false;stop_selected()
   KEY_Z:repairs.toggle()
   KEY_ESCAPE:attack_cursor=false;build_mode='';selected.clear();refresh_commands()
   KEY_Q,KEY_E:
    if not selected.is_empty():
     var b=selected[0]
     if b.kind=='Castle':train('Pawn',b)
     if b.kind=='Barracks':train('Archer' if e.keycode==KEY_E else 'Warrior',b)
     if b.kind=='Workshop' and e.keycode==KEY_Q:train('Catapult',b)
     if b.kind=='Smith':technology.research(b,'armor' if e.keycode==KEY_E else 'attack')
 if e is InputEventMouseButton:
  if not field_rect().has_point(e.position):return
  if e.button_index==MOUSE_BUTTON_LEFT:
   if e.pressed:
    if build_mode!='':place_building(world_mouse());return
    if attack_cursor:
     order(world_mouse(),null,'attack_move');attack_cursor=false;return
    drag=true;drag_start=world_mouse()
   elif drag:
    drag=false
    var box=Rect2(drag_start,world_mouse()-drag_start).abs()
    if not Input.is_key_pressed(KEY_SHIFT):selected.clear()
    if box.size.length()>12:
     for u in units:
      if u.team==0 and box.has_point(u.p) and not contains_entity(selected,u):selected.append(u)
    else:
     var hit=pick(world_mouse(),true)
     if hit!=null and not contains_entity(selected,hit):selected.append(hit)
    refresh_commands()
  if e.button_index==MOUSE_BUTTON_RIGHT and e.pressed:
   if build_mode!='':build_mode='';return
   order(world_mouse(),pick(world_mouse(),false))
func pick(p,own):
 var best=null
 var dist=35.0
 for u in units:
  if own and u.team!=0:continue
  if u.team!=0 and not fog.sees(0,u.p):continue
  var d=(u.p-Vector2(0,18)).distance_to(p)
  if d<dist:best=u;dist=d
 if best!=null:return best
 for b in buildings:
  if own and b.team!=0:continue
  if b.team!=0 and not fog.sees(0,b.p):continue
  if art.building_rect(b).has_point(p):return b
 if not own:
  var trees=resources.filter(func(r):return r.kind=='wood' and r.amount>0 and fog.sees(0,r.p))
  trees.sort_custom(func(a,b):return a.p.y>b.p.y)
  for tree in trees:
   if art.tree_hit(tree,p):return tree
  for r in resources:
   if r.amount<=0 or not fog.sees(0,r.p):continue
   if r.kind!='wood' and r.p.distance_to(p)<35:return r
 return null
func order(p,hit,mode="move"):
 if outcome!='':return
 issue_order(selected,p,hit,mode)
 if not selected.is_empty():sfx.play("command")
func issue_order(group,p,hit,mode="move"):
 if outcome!='':return
 var i=0
 var members=group.filter(func(u):return contains_entity(units,u))
 for u in members:u.formation=-1
 for u in group:
  if contains_entity(buildings,u):
   if u.kind not in ['Castle','Barracks','Workshop']:continue
   u['rally_resource']=hit if u.kind=='Castle' and hit!=null and contains_entity(resources,hit) and hit.amount>0 else null
   if u.rally_resource!=null:
    u['rally_unit']=null;u.rally=hit.p;u['spawned']=0
    tell('Resource rally set. New workers will gather '+hit.kind+'.');continue
   u['rally_unit']=hit if hit!=null and contains_entity(units,hit) and hit.team==u.team and hit.hp>0 else null
   if u.rally_unit!=null:
    u.rally=hit.p;tell('Rally set to unit. New units will follow it.');continue
   if nav_dirty:rebuild_nav()
   u.rally=Vector2(nearest_cell(p))*20+Vector2(10,10);u['spawned']=0;tell('Rally point set. Newly trained units will move here.');continue
  repairs.clear(u)
  u['follow_unit']=null
  u.returning=false;u.windup=0.0;u.pending=null;u.swing_time=-1.0;u.target=null;u.job=null;u.mode=mode;u.path=PackedVector2Array()
  u.goal=p+Vector2((i%4-1.5)*30,(i/4)*30);i+=1
  if hit!=null:
   if hit.has('amount') and u.kind=='Pawn':u.job=hit;u.returning=u.carry>0 and u.carry_kind!=hit.kind
   elif hit.has('team') and hit.team!=u.team:u.target=hit;u.mode='attack'
   elif hit.has('progress') and hit.progress<1 and u.kind=='Pawn':u.job=hit;u.returning=u.carry>0
   elif u.kind=='Pawn' and repairs.valid(u,hit):repairs.assign(u,hit)
 if hit==null and members.size()>1:create_formation(members,p,mode)
 effects.append({"p":p,"life":0.7,"text":"","color":Color('#ffe5a0'),"resource_order":hit!=null and hit.has("amount")})
func place_building(p):
 return economy.place(build_mode,p,selected.filter(func(u):return u.kind=='Pawn' and u.team==0 and u.hp>0))
func field_rect():return Rect2(Vector2(0,72),get_viewport_rect().size-Vector2(0,240))
func minimap_rect():return Rect2(Vector2(23,get_viewport_rect().size.y-145),Vector2(200,125))
func camera_limit():return WORLD-Vector2(field_rect().size.x,field_rect().end.y)
func land(p):
 if map_style=='plains':return p.x>80 and p.x<WORLD.x-80 and p.y>110 and p.y<WORLD.y-110
 return p.x>80 and p.x<WORLD.x-80 and p.y>110 and p.y<WORLD.y-110 and (abs(p.x-WORLD.x/2)>108 or CROSSINGS.any(func(span):return p.y>span.x and p.y<span.y))
func crossing_reserved(area):
 for span in CROSSINGS:
  if area.intersects(Rect2(WORLD.x/2-160,span.x-32,320,span.y-span.x+64)):return true
 return false
func walkable(p):
 if not land(p):return false
 for b in buildings:
  if b.hp>0 and abs(p.x-b.p.x)<(92 if b.kind=='Castle' else 57) and abs(p.y-b.p.y)<45:return false
 return true
func nav_clear(p):
 for offset in [Vector2(-10,-10),Vector2(10,-10),Vector2(-10,10),Vector2(10,10)]:
  if not walkable(p+offset):return false
 return true
func rebuild_nav():
 nav.region=Rect2i(Vector2i.ZERO,Vector2i(WORLD/20));nav.cell_size=Vector2(20,20);nav.offset=Vector2(10,10)
 nav.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES;nav.update()
 for y in range(int(WORLD.y/20)):
  for x in range(int(WORLD.x/20)):nav.set_point_solid(Vector2i(x,y),not nav_clear(Vector2(x*20+10,y*20+10)))
 nav_dirty=false
func nearest_cell(p):
 var base=Vector2i(p/20).clamp(Vector2i.ZERO,Vector2i(WORLD/20)-Vector2i.ONE)
 if not nav.is_point_solid(base):return base
 for radius in range(1,15):
  var best=base;var distance=INF
  for y in range(-radius,radius+1):
   for x in range(-radius,radius+1):
    var c=base+Vector2i(x,y)
    if nav.is_in_boundsv(c) and not nav.is_point_solid(c):
     var gap=p.distance_squared_to(Vector2(c)*20+Vector2(10,10))
     if gap<distance:best=c;distance=gap
  if distance<INF:return best
 return base
func segment_clear(a,b):
 var steps=max(1,int(ceil(a.distance_to(b)/10.0)))
 for i in range(1,steps+1):
  if not nav_clear(a.lerp(b,float(i)/steps)):return false
 return true
func move_unit(u,p,dt,stop=5):
 var before=u.p;var facing=u.face
 var arrived=move_unit_path(u,p,dt,stop)
 u.moving=u.p.distance_squared_to(before)>0.0001
 if abs(u.p.x-before.x)>0.1:u.face=1 if u.p.x>before.x else -1
 else:u.face=facing
 return arrived
func move_unit_path(u,p,dt,stop=5):
 if nav_dirty:rebuild_nav()
 # A shared rally destination may already be occupied by a resting ally.
 if contains_entity(units,u) and u.kind!="Pawn" and u.target==null and u.job==null and u.formation<0 and u.p.distance_to(p)<30:
  for ally in units:
   if is_same(ally,u) or ally.team!=u.team or ally.hp<=0 or ally.moving:continue
   if ally.p.distance_to(p)<22 and u.p.distance_to(ally.p)<=24:
    u.goal=u.p;u.path=PackedVector2Array();return true
 if u.formation>=0 and u.target==null and u.job==null and segment_clear(u.p,p):
  var delta=p-u.p
  # Once the slot stops, use an arrival tolerance instead of an exponential tail.
  # Moving slots bypass this so marching does not alternate between move and idle.
  if u.slot_velocity.length()<0.1 and delta.length()<=4.0:
   u.path=PackedVector2Array();u.moving=false;return true
  var velocity=(u.slot_velocity+delta*4.0).limit_length(move_speed(u))
  if u.slot_velocity.length()<0.1 and delta.length()<0.5:velocity=Vector2.ZERO
  blocking.move(u,u.p.move_toward(p,velocity.length()*dt))
  if abs(delta.x)>1.5 and abs(velocity.x)>8:u.face=1 if velocity.x>0 else -1
  u.moving=velocity.length()>2
  u.path=PackedVector2Array()
  return delta.length()<0.5
 u.moving=u.p.distance_to(p)>stop
 if not u.moving:return true
 if segment_clear(u.p,p):
  var direction=p-u.p
  if abs(direction.x)>2:u.face=1 if direction.x>0 else -1
  blocking.move(u,u.p.move_toward(p,dt*move_speed(u)))
  u.path=PackedVector2Array()
  return u.p.distance_to(p)<=stop
 if u.path.is_empty() or u.path_goal.distance_to(p)>30:
  u.path=nav.get_point_path(nearest_cell(u.p),nearest_cell(p));u.path_goal=p
  if u.path.size()>1 and segment_clear(u.p,u.path[1]):u.path.remove_at(0)
 if u.path.is_empty():u.moving=false;return false
 if u.path.size()==1 and nav_clear(p) and u.p.distance_to(p)<35:
  blocking.move(u,u.p.move_toward(p,dt*move_speed(u)))
  return u.p.distance_to(p)<=stop
 var target=u.path[0]
 var d=target-u.p
 u.face=1 if d.x>=0 else -1
 var next=u.p.move_toward(target,dt*move_speed(u))
 if walkable(next):blocking.move(u,next)
 if u.p.distance_to(target)<3:u.path.remove_at(0)
 return false
func stop_selected():
 if not selected.is_empty():sfx.play("command")
 for u in selected:
  if contains_entity(buildings,u):continue
  repairs.clear(u)
  u['follow_unit']=null
  u.returning=false;u.windup=0.0;u.pending=null;u.swing_time=-1.0;u.formation=-1;u.target=null;u.job=null;u.goal=u.p;u.mode='stop';u.path=PackedVector2Array()
 tell('Stopped. A: attack move · Right-click: move / retreat')
func _process(dt):
 if match_video and not match_substep:
  match_substep=true
  for i in range(4):_process(1.0/30.0)
  match_substep=false
  queue_redraw();RenderingServer.force_draw(false)
  return
 if formation_video or combat_video or economy_video or ai_video or map_video or roles_video or match_video or blocking_video or results_video or defense_video or arrival_video or polish_video or blue_orders_video or woodland_video:dt=1.0/30.0
 sound_cool-=dt
 sfx.tick(dt)
 if not paused and outcome=='':
  time+=dt;raid-=dt
  fog.tick(dt)
  if match_video:match_driver.tick(dt)
  if ai_enabled:opponent.tick(dt)
  for b in buildings:
   var leader=b.get('rally_unit')
   if leader!=null:
    b.rally=leader.p
    if leader.hp<=0 or not contains_entity(units,leader):b.rally_unit=null
   b.cool-=dt
   if b.progress<1:continue
   economy.tick_training(b,dt)
   technology.tick(b,dt)
   if b.kind=='Tower':tower_upgrades.tick(b,dt)
  update_formations(dt)
  var frame_positions=units.map(func(u):return u.p)
  for u in units:
   u.cool-=dt;u.tick+=dt;u.moving=false
   u.hurt_time=maxf(0,u.get("hurt_time",0)-dt)
   if u.swing_time>=0:
    u.swing_time+=dt
    if u.swing_time>0.60:u.swing_time=-1.0
   if u.target!=null and u.mode=='guard' and u.target.p.distance_to(u.goal)>260:
    u.target=null;u.pending=null;u.windup=0.0;u.swing_time=-1.0
   if u.target!=null and (u.target.hp<=0 or not fog.sees(u.team,u.target.p)):u.target=null;u.pending=null;u.windup=0.0;u.swing_time=-1.0
   if u.kind!='Pawn' and u.target==null and u.mode in ['guard','attack_move','follow']:
    var closest=400.0 if u.kind=='Catapult' else 220.0
    for v in units+buildings:
     if v.team!=u.team and v.hp>0 and fog.sees(u.team,v.p) and (u.mode!='guard' or v.p.distance_to(u.goal)<=260) and u.p.distance_to(v.p)<closest:closest=u.p.distance_to(v.p);u.target=v
   if u.target!=null:
    combat_step(u,dt)
   elif u.mode=='follow':follow_step(u,dt)
   elif u.kind=='Pawn':economy.work(u,dt)
   else:move_unit(u,u.goal,dt)
  separate(dt)
  for i in range(units.size()):
   var u=units[i]
   u.moving=u.p.distance_to(frame_positions[i])>dt*3.0
   if u.moving:
    u.motion_hold=0.15
    var travel=u.p.distance_to(frame_positions[i])
    u.stride=fposmod(u.stride+travel/(80.0 if u.kind=='Cavalry' else 44.0),1.0)
    u.step_distance+=travel
    if u.step_distance>=22:
     u.step_distance=fmod(u.step_distance,22)
     sfx.play("step",u.p)
   else:u.motion_hold=max(0.0,u.motion_hold-dt)
  for s in shots:
   s.p=s.p.move_toward(s.end,dt*(240 if s.get("siege",false) else 470))
   s.flight+=dt
   if s.p.distance_to(s.end)<1:
    if s.get('siege',false):
     for victim in units+buildings:
      if victim.team!=s.team and victim.hp>0 and target_point(victim,s.end).distance_to(s.end)<=55:
       damage(victim,maxf(1,(90 if contains_entity(buildings,victim) else 24)+s.attack_bonus-armor_value(victim)))
     sfx.play('collapse',s.end);effects.append({'p':s.end,'life':0.65,'text':'','color':Color('#c1a078')})
    elif s.get('tower_branch','')=='cannon':
     for victim in units:
      if victim.team!=s.team and victim.hp>0 and victim.p.distance_to(s.end)<=s.blast_radius:damage(victim,maxf(1,s.raw_damage-armor_value(victim)))
     sfx.play('tower_cannon_hit',s.end);effects.append({'p':s.end,'life':0.4,'text':'','tower_hit':'cannon','color':Color.WHITE})
    elif s.target.hp>0 and target_point(s.target,s.end).distance_to(s.end)<=24:
     damage(s.target,s.damage)
     if s.get('tower_branch','')!='':
      var branch=s.tower_branch
      if branch=='cannon':sfx.play('tower_cannon_hit',s.end)
      effects.append({'p':s.end,'life':0.4,'text':'','tower_hit':branch,'color':Color.WHITE})
     if s.get('shield',false):s.target['shield_until']=time+0.22
    s.dead=true
  shots=shots.filter(func(s):return not s.dead)
  var fallen=[false,false]
  for u in units+buildings:
   if u.hp<=0:match_results.lost(u)
  for b in buildings:
   if b.hp<=0:nav_dirty=true
   if b.hp<=0 and b.kind=='Castle':fallen[b.team]=true
  if fallen[0] or fallen[1]:
   outcome='DRAW' if fallen[0] and fallen[1] else ('DEFEAT' if fallen[0] else 'VICTORY')
   match_results.finish(outcome,time)
  units=units.filter(func(u):return u.hp>0)
  buildings=buildings.filter(func(b):return b.hp>0)
  selected=selected.filter(func(u):return u.hp>0)
  supply.tick(dt)
 for fx in effects:fx.life-=dt
 effects=effects.filter(func(fx):return fx.life>0)
 note_timer-=dt
 if camera_controls!=null:camera_controls.tick(dt)
 cam=cam.clamp(Vector2(0,-72),camera_limit())
 if stats!=null:
  stats.text='GOLD  %d      WOOD  %d      POP  %d / %d       %02d:%02d'%[gold,wood,population(),capacity(),int(time)/60,int(time)%60]
  details.text=('DESTROY ENEMY TOWN CENTER\nCamps: bonus gold + wood.' if supply.enabled else 'RIVER CROSSING\nDestroy the red Town Center.\n'+pace_hint()) if selected.is_empty() else '%s  × %d\nHealth: %d / %d\n%s'%[NAMES[selected[0].kind],selected.size(),selected[0].hp,selected[0].max,selection_status()]
  message.text=note if note_timer>0 else pace_hint()+'    |    F: army    R: enemy base    . : worker'
  result.text='PAUSED' if paused and outcome=='' and not settings_menu.is_open() else ''
  icon_hud.update()
 if demo:demo_step()
 if review:review_tick()
 if formation_video:formation_video_tick()
 if combat_video:combat_video_tick()
 if economy_video:economy_video_tick()
 if ai_video:
  message.text='AI ECONOMY | Gold %d  Wood %d | Pop %d/%d | Delivered %d | Trained %d | %s'%[enemy_money.x,enemy_money.y,population(1),capacity(1),enemy_gathered,enemy_trained,opponent.state]
  var march=units.filter(func(u):return u.team==1 and u.kind!='Pawn' and u.mode=='attack_move')
  if not march.is_empty():
   var lead=march[0]
   for u in march:
    if u.p.x<lead.p.x:lead=u
   cam=cam.lerp((lead.p-Vector2(680,390)).clamp(Vector2(0,-72),camera_limit()),0.06)
  if time>140:get_tree().quit()
 if map_video:map_video_tick()
 if roles_video:roles_demo.tick()
 if blocking_video:blocking_demo.tick()
 if results_video:results_demo.tick()
 if defense_video:defense_demo.tick()
 if arrival_video:arrival_demo.tick()
 if polish_video:polish_demo.tick()
 if blue_orders_video:blue_orders_demo.tick()
 if woodland_video:woodland_demo.tick()
 if match_video:
  match_driver.camera()
  if outcome!='':
   match_finish_wait+=dt
   if match_finish_wait>3:
    var report=match_driver.report()
    if '--observe-match' in OS.get_cmdline_user_args() or '--blue-vision-review' in OS.get_cmdline_user_args():
     var path='res://captures/blue-vision-match-metrics.json' if '--blue-vision-review' in OS.get_cmdline_user_args() else 'res://captures/large-map-1v1-metrics.json'
     report['view']='blue' if not fog.observer else 'observer'
     var file=FileAccess.open(path,FileAccess.WRITE);file.store_string(JSON.stringify(report,'  '))
    print('MATCH VIDEO ',report);get_tree().quit()
 supply.update_ui()
 update_economy_hud()
 queue_redraw()
 if formation_video or combat_video or economy_video or ai_video or map_video or roles_video or blocking_video or results_video or defense_video or arrival_video or polish_video or blue_orders_video or woodland_video:RenderingServer.force_draw(false)
func pace_hint():
 if outcome!='':return 'Match ended: review results or play again'
 if supply!=null and supply.enabled:return 'Destroy enemy Town Center | Camps: +12 gold / +6 wood every 10s | F: army, T/Y: send'
 if time<150:return 'Prepare: workers, house, barracks (%ds)'%int(ceil(150-time))
 if time<300:return 'Contest: defend routes and secure rich gold'
 return 'Push: replace losses and attack production'
func selection_status():
 var u=selected[0]
 if u.get('follow_unit')!=null:return 'Following '+NAMES[u.follow_unit.kind]
 if u.get('rally_resource')!=null:return 'Rally: gather '+u.rally_resource.kind
 if u.get('rally_unit')!=null:return 'Rally: '+NAMES[u.rally_unit.kind]
 if not u.queue.is_empty():return 'Training: '+str(u.queue.size())+' queued · '+str(int(u.train))+'s'
 if u.progress<1:return 'Construction: %d%% — assign workers'%int(u.progress*100)
 if u.kind=='Pawn':return '%s · %d/15 %s'%[u.work_state,u.carry,u.carry_kind]
 if contains_entity(buildings,u):return 'Right-click ground, friendly unit or resource to rally' if u.kind in ['Castle','Barracks','Workshop'] else role_text(u.kind)
 return role_text(u.kind)
func separate(dt):
 for i in range(units.size()):
  for j in range(i):
   var a=units[i];var b=units[j];var d=a.p-b.p
   if a.team!=b.team:continue
   # Formation slots already provide spacing. Pushing these allies fights the
   # slot controller during turns and creates a feedback loop.
   if a.formation>=0 and a.formation==b.formation and a.target==null and b.target==null:continue
   var spacing=blocking.radius(a)+blocking.radius(b)-2.0
   if d.length()<spacing and d.length()>0.1:
    var push=d.normalized()*min((spacing-d.length())*0.5,dt*65)
    if walkable(a.p+push):blocking.move(a,a.p+push,false)
    if walkable(b.p-push):blocking.move(b,b.p-push,false)
func footprint(b):
 return Vector2(92 if b.kind=='Castle' else 57,45)
func target_point(v,from):
 if contains_entity(buildings,v):
  var half=footprint(v)
  return from.clamp(v.p-half,v.p+half)
 return v.p
func combat_gap(u,v):
 return max(0.0,u.p.distance_to(target_point(v,u.p))-(0.0 if contains_entity(buildings,v) else 16.0))
func base_attack(u):
 if u.kind=='Tower':return tower_upgrades.attack(u)
 return {'Pawn':15.0,'Warrior':23.0,'Archer':24.0,'Tower':24.0,'Spearman':18.0,'Catapult':24.0,'Cavalry':28.0}.get(u.kind,0.0)+technology.bonus(u,'attack')
func armor_value(u):return (2 if u.kind=='Cavalry' else 0)+technology.bonus(u,'armor')
func attack_interval(u):
 if u.kind=='Tower':return tower_upgrades.interval(u)
 return 3.2 if u.kind=='Catapult' else (1.2 if u.kind=='Tower' else 1.0)
func move_speed(u):
 var speed=140.0 if u.kind=='Cavalry' else (55.0 if u.kind=='Catapult' else (100.0 if u.kind=='Pawn' else 92.0))
 return speed
func attack_range(u):
 if u.kind=='Tower':return tower_upgrades.reach(u)
 if u.kind=='Catapult':return 330.0
 if u.kind=='Spearman':return 42.0
 if u.kind=='Cavalry':return 24.0
 return 260.0 if u.kind=='Tower' else (194.0 if u.kind=='Archer' else 18.0)
func attack_clear(u,v):
 var end=target_point(v,u.p)
 var steps=max(1,int(ceil(u.p.distance_to(end)/8)))
 for i in range(1,steps):
  var p=u.p.lerp(end,float(i)/steps)
  if u.kind not in ['Archer','Tower','Catapult'] and not land(p):return false
  for b in buildings:
   if is_same(b,u) or is_same(b,v):continue
   if Rect2(b.p-footprint(b),footprint(b)*2).has_point(p):return false
 return true
func can_attack(u,v):
 if u.kind=='Catapult' and combat_gap(u,v)<75:return false
 return v.hp>0 and fog.sees(u.team,v.p) and combat_gap(u,v)<=attack_range(u)+0.01 and attack_clear(u,v)
func combat_step(u,dt):
 var v=u.target
 var direction=v.p-u.p
 if abs(direction.x)>1:u.face=1 if direction.x>0 else -1
 if u.kind=='Catapult' and combat_gap(u,v)<75:
  u.windup=0;u.pending=null
  move_unit(u,u.p+(u.p-v.p).normalized()*120,dt,5);return
 if u.windup>0:
  u.windup=max(0.0,u.windup-dt)
  if u.windup==0:
   if is_same(u.pending,v) and can_attack(u,v):
    if u.kind in ['Archer','Catapult']:fire(u,v,base_attack(u))
    else:
     log_attack(u,v,'melee impact')
     sfx.play('swing',u.p)
     damage(v,strike_damage(u,v,base_attack(u)))
   u.pending=null
  return
 if can_attack(u,v):
  u.path=PackedVector2Array()
  if u.cool<=0:
   u.cool=attack_interval(u);u.windup=0.24;u.pending=v;u.swing_time=0.0
  return
 var aim=target_point(v,u.p)
 if contains_entity(buildings,v):aim+=(u.p-aim).normalized()*16
 move_unit(u,aim,dt,2)
func log_attack(u,v,kind):
 combat_events.append({'time':time,'kind':kind,'unit':u.kind,'target':v.kind,'gap':combat_gap(u,v),'limit':attack_range(u),'center':u.p.distance_to(v.p)})
 if combat_events.size()>500:combat_events.pop_front()
func fire(u,v,d):
 if not can_attack(u,v):return
 log_attack(u,v,'projectile launch')
 var tower_branch=tower_upgrades.branch(u) if u.kind=='Tower' else ''
 sfx.play({'arrow':'tower_rapid','cannon':'tower_cannon'}.get(tower_branch,'bolt'),u.p)
 if tower_branch!='':u['shot_at']=time
 shots.append({'blast_radius':tower_upgrades.splash(u) if tower_branch=='cannon' else 0.0,'raw_damage':d,'muzzle_height':art.building_rect(u).size.y*0.65 if u.kind=='Tower' else 25.0,'tower_branch':tower_branch,'p':u.p,'end':target_point(v,u.p),'target':v,'damage':strike_damage(u,v,d),'shield':v.kind=='Warrior','siege':u.kind=='Catapult','team':u.team,'attack_bonus':technology.bonus(u,'attack'),'start':u.p,'flight':0.0,'dead':false})
func strike_damage(u,v,base):
 var amount=float(base)
 if u.kind=='Tower' and tower_upgrades.branch(u)=='cannon':return maxf(1.0,amount-armor_value(v))
 if u.kind=='Warrior' and contains_entity(buildings,v):amount=32.0+technology.bonus(u,'attack')
 if u.kind=='Spearman' and v.kind=='Warrior':amount+=9.0
 if u.kind=='Spearman' and v.kind=='Cavalry':amount+=18.0
 if u.kind=='Archer':
  if contains_entity(buildings,v):amount=6.0+technology.bonus(u,'attack')
  elif u.p.distance_to(v.p)<64:amount*=0.5
 if u.kind in ['Archer','Tower'] and v.kind=='Warrior':amount=max(1.0,amount-6.0)
 return maxf(1.0,amount-armor_value(v))
func role_text(kind):
 return {'Cavalry':'Mounted knight | Speed 140 | Armor 2 | Weak to spearmen','Warrior':'Front line | blocks 6 arrow damage | 32 vs buildings','Archer':'Ranged support | half damage within 64px | 6 vs buildings','Spearman':'Reach 42 | +18 vs cavalry | +9 vs swordsmen','Catapult':'Siege | 90 vs buildings | splash 55 | minimum range 75','Smith':'Two levels: attack +3 / armor +2 | existing and future troops','Depot':'Local gold and wood delivery | Protect your expansion','Workshop':'Trains catapults | Protect siege with infantry','Tower':'Area defense | 260px range | vulnerable to massed melee'}.get(kind,'')
func damage(v,d):
 if outcome!='':return
 if v.hp<=0:return
 sfx.play("metal" if v.kind in ["Warrior","Tower"] else "hit",v.p)
 effects.append({'p':v.p-Vector2(0,26),'life':0.18,'text':'','color':Color('#ffe5a0'),'impact':true})
 v['hurt_time']=0.16
 v.hp-=d;floating(v.p,'−'+str(d),Color('#fff0cb'))
 if v.hp<=0:
  sfx.play("collapse" if contains_entity(buildings,v) else "death",v.p)
  kills+=1;effects.append({"p":v.p,"life":0.8,"text":"✦","color":Color('#edb46b')})
func floating(p,s,c):effects.append({"p":p-Vector2(0,40),"life":0.9,"text":s,"color":c})
func sprite(key,p,scale_factor=0.65,animated=false,flip=1.0,mod=Color.WHITE,anim_clock=-1.0):
 art.sprite(key,p,scale_factor,animated,flip,mod,anim_clock)

func _draw():
 draw_rect(Rect2(Vector2.ZERO,get_viewport_rect().size),Color('#3e7f87'))
 draw_set_transform(-cam)
 art.terrain()
 supply.draw_world()
 for b in buildings:
  if fog.render_known(0,b.p) and (b.team==0 or fog.render_sees(0,b.p)):art.building_ground(b)
 var things=resources.filter(func(r):return r.amount>0)+buildings+units
 things.sort_custom(func(a,b):return a.p.y<b.p.y)
 for e in things:
  if e.has("team") and e.team!=0 and not fog.render_sees(0,e.p):continue
  if not fog.render_known(0,e.p):continue
  art.shadow_entity(e)
 for e in things:
  if e.has("team") and e.team!=0 and not fog.render_sees(0,e.p):continue
  var p=e.p
  if p.x<cam.x-180 or p.x>cam.x+field_rect().size.x+160 or p.y<cam.y-180 or p.y>cam.y+get_viewport_rect().size.y:continue
  if e.has('amount'):
   if e.kind=='wood':
    var obscures=units.any(func(u):return u.hp>0 and fog.render_sees(0,u.p) and abs(u.p.x-p.x)<50 and u.p.y<p.y+5 and u.p.y>p.y-90)
    sprite('Tree3' if int(p.x)%3==0 else 'TreeSmall',p-Vector2(0,40),0.64,false,1,Color(1,1,1,0.45 if obscures else 1.0))
   else:
    if e.get('zone','')=='RICH':
     draw_circle(p,38,Color(0.95,0.74,0.25,0.18))
     sprite('Gold Stone 1',p+Vector2(-22,-5),0.65)
     sprite('Gold Stone 1',p+Vector2(22,-5),0.65)
    sprite('Gold Stone 1',p-Vector2(0,12),0.8)
    if e.has('zone'):draw_string(ThemeDB.fallback_font,p+Vector2(-32,53),e.zone+' GOLD',HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color('#ffe4a2'))
    if not fog.render_sees(0,p):draw_string(ThemeDB.fallback_font,p+Vector2(-4,35),'?',HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color('#f4e6ad'))
   continue
  var color=Color('#51b6ad') if e.team==0 else Color('#ee8a6f')
  if contains_entity(selected,e):
   if contains_entity(units,e):
    var half_width=27.0 if e.kind=='Cavalry' else 18.0
    # Short ground-plane brackets follow the logical feet, not animation bobbing.
    for side in [-1,1]:
     var edge=p+Vector2(side*half_width,2)
     var mark=PackedVector2Array([edge+Vector2(-side*5,-4),edge,edge+Vector2(-side*5,4)])
     draw_polyline(mark,Color(0.10,0.23,0.19,0.45),3.0,true)
     draw_polyline(mark,Color(0.54,0.77,0.65,0.85),1.5,true)
   else:art.draw_building_selection(e)
  var key=art.entity_key(e)
  if contains_entity(units,e):
   art.draw_unit(e)
   if e.get('shield_until',0)>time:draw_arc(p-Vector2(0,17),24,-2.5,-0.6,14,Color('#c3edff'),3)
   if e.carry>0:draw_circle(p+Vector2(13,-30),5,Color('#e5bb50') if e.carry_kind=='gold' else Color('#aa7247'))
  else:
   art.sprite(key,p-Vector2(0,45),0.8,false,1,Color(1,1,1,0.4+0.6*e.progress),-1,e)
   if e.kind=='Tower':tower_upgrades.draw(e)
   if e.progress<1:
    for dx in [-48,48]:draw_line(p+Vector2(dx,18),p+Vector2(dx,-75),Color('#b9915f'),4)
    draw_line(p+Vector2(-53,-50),p+Vector2(53,-50),Color('#e0bb80'),4)
    draw_line(p+Vector2(-48,18),p+Vector2(48,-50),Color('#b9915f'),3)
   if not e.queue.is_empty():
    draw_rect(Rect2(p+Vector2(-40,40),Vector2(80,5)),Color('#43321e'))
    draw_rect(Rect2(p+Vector2(-40,40),Vector2(80*e.train/(5 if e.queue[0]=='Pawn' else 8),5)),Color('#e4c77b'))
  if contains_entity(units,e) and e.kind=='Pawn' and e.team==0 :
   pass # Worker captions are rendered above all world sprites below.
  if combat_video and e.team==0 and e.target!=null:
   draw_string(ThemeDB.fallback_font,p+Vector2(-48,-88),'gap %.0f / %.0f'%[combat_gap(e,e.target),attack_range(e)],HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color('#fff0b0'))
  if e.hp<e.max or e.progress<1 or contains_entity(selected,e):
   var width=40 if contains_entity(units,e) else 96
   var pos=p+Vector2(-width/2,(-80 if e.kind=='Cavalry' else -64) if contains_entity(units,e) else -art.building_rect(e).size.y-4)
   draw_rect(Rect2(pos,Vector2(width,5)),Color('#3a3528'))
   draw_rect(Rect2(pos,Vector2(width*max(0,e.hp)/e.max,5)),color)
 for s in shots:
  if not fog.render_sees(0,s.p):continue
  if s.get('siege',false):
   var ratio=clampf(s.start.distance_to(s.p)/maxf(1,s.start.distance_to(s.end)),0,1)
   draw_circle(s.p,7,Color(0.1,0.12,0.1,0.25));draw_circle(s.p-Vector2(0,22+sin(ratio*PI)*80),7,Color('#aaa28f'));continue
  if s.get('tower_branch','')!='':tower_upgrades.draw_projectile(s);continue
  var dir=(s.end-s.p).normalized();var head=s.p-Vector2(0,25)+dir*12
  draw_line(head-dir*15,head,Color('#b99562'),2,true)
  draw_colored_polygon(PackedVector2Array([head+dir*4,head-dir*3+dir.orthogonal()*3,head-dir*3-dir.orthogonal()*3]),Color('#e4e5cc'))
 for fx in effects:
  if not fog.render_sees(0,fx.p):continue
  if fx.has('tower_hit'):tower_upgrades.draw_impact(fx);continue
  if fx.get('impact',false):
   var fade=clampf(fx.life/0.18,0,1)
   for i in range(5):
    var direction=Vector2.from_angle(i*TAU/5+0.3)
    draw_line(fx.p+direction*(3+(1-fade)*8),fx.p+direction*(9+(1-fade)*12),Color(1,0.87,0.55,fade),2,true)
   continue
  if fx.get('resource_order',false):
   var fade=clampf(fx.life/0.35,0.0,1.0)
   for side in [-1,1]:
    var edge=fx.p+Vector2(side*25,1)
    var mark=PackedVector2Array([edge+Vector2(-side*6,-4),edge,edge+Vector2(-side*6,4)])
    draw_polyline(mark,Color(0.12,0.23,0.18,0.35*fade),3,true)
    draw_polyline(mark,Color(0.66,0.78,0.57,0.8*fade),1.5,true)
   continue
  if fx.text=='':draw_arc(fx.p,32*(1-fx.life/0.7),0,TAU,32,fx.color,2)
  else:draw_string(ThemeDB.fallback_font,fx.p-Vector2(0,(1-fx.life)*30),fx.text,HORIZONTAL_ALIGNMENT_CENTER,-1,17,fx.color)
 for e in resources:
  if e.kind!='gold' or e.amount<=0 or not fog.render_sees(0,e.p):continue
  var p=e.p
  if not Rect2(cam+field_rect().position,field_rect().size).has_point(p):continue
  var miners=units.filter(func(u):return u.team==0 and u.hp>0 and u.kind=='Pawn' and is_same(u.job,e))
  var font=ThemeDB.fallback_font
  var amount_text=str(e.amount)
  var count_text=str(miners.size())
  var amount_width=font.get_string_size(amount_text,HORIZONTAL_ALIGNMENT_LEFT,-1,13).x
  var count_width=font.get_string_size(count_text,HORIZONTAL_ALIGNMENT_LEFT,-1,13).x
  var left=p+Vector2(-(18+amount_width+14+14+count_width)/2,35)
  draw_texture_rect(icon_hud.icons['gold'],Rect2(left+Vector2(0,-14),Vector2(16,16)),false)
  draw_string_outline(font,left+Vector2(18,0),amount_text,HORIZONTAL_ALIGNMENT_LEFT,-1,13,3,Color('#373b28'))
  draw_string(font,left+Vector2(18,0),amount_text,HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color('#f4e6ad'))
  var person=left+Vector2(18+amount_width+14,-10)
  draw_circle(person+Vector2(4,0),2.5,Color('#b4dfbd'))
  draw_line(person+Vector2(0,9),person+Vector2(0,6),Color('#b4dfbd'),2,true)
  draw_line(person+Vector2(0,6),person+Vector2(8,6),Color('#b4dfbd'),2,true)
  draw_line(person+Vector2(8,6),person+Vector2(8,9),Color('#b4dfbd'),2,true)
  draw_string_outline(font,person+Vector2(14,10),count_text,HORIZONTAL_ALIGNMENT_LEFT,-1,13,3,Color('#373b28'))
  draw_string(font,person+Vector2(14,10),count_text,HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color('#b4dfbd'))
 fog.draw_world()
 if drag:draw_rect(Rect2(drag_start,world_mouse()-drag_start).abs(),Color(1,0.9,0.55,0.15));draw_rect(Rect2(drag_start,world_mouse()-drag_start).abs(),Color('#ffe09b'),false,1)
 if build_mode!='':
  var pos=preview_position if preview_override else world_mouse()
  var workers=selected.filter(func(u):return u.kind=='Pawn' and u.team==0 and u.hp>0)
  var reason=economy.placement_reason(build_mode,pos,workers)
  var tint=Color('#8fe0a5') if reason=='' else Color('#ef817c')
  draw_rect(Rect2(pos-Vector2(57,45),Vector2(114,90)),Color(tint,0.22))
  draw_rect(Rect2(pos-Vector2(57,45),Vector2(114,90)),tint,false,2)
  sprite('Blue_'+build_mode,pos-Vector2(0,45),0.8,false,1,Color(tint,0.65))
  draw_string(ThemeDB.fallback_font,pos+Vector2(-80,75),'Click to build · %d wood'%cost(build_mode) if reason=='' else reason,HORIZONTAL_ALIGNMENT_LEFT,-1,15,tint)
 for b in selected:
  if contains_entity(buildings,b) and b.kind in ['Castle','Barracks','Workshop']:
   var leader=b.get('rally_unit')
   var flag=leader.p if leader!=null and leader.hp>0 else b.rally
   draw_line(flag,flag-Vector2(0,42),Color('#f6e3a2'),3)
   draw_colored_polygon(PackedVector2Array([flag-Vector2(0,42),flag+Vector2(24,-34),flag-Vector2(0,25)]),Color('#68c8ee'))
 draw_set_transform(Vector2.ZERO)
 draw_set_transform(Vector2(0,get_viewport_rect().size.y-900))
 # Minimap remains readable while the main view scrolls.
 draw_rect(Rect2(0,732,240,168),Color('#292219'))
 draw_rect(Rect2(18,750,210,140),Color('#172e2d'))
 draw_rect(Rect2(23,755,92,125),Color('#8ba352'));draw_rect(Rect2(132,755,91,125),Color('#8ba352'))
 if map_style=='plains':draw_rect(Rect2(23,755,200,125),Color('#8ba352'))
 for span in ([] if map_style=='plains' else CROSSINGS):
  var y=755+(span.x+span.y)*0.5/WORLD.y*125
  draw_line(Vector2(112,y),Vector2(134,y),Color('#b58b5d'),8)
 for r in resources:
  if r.kind=='gold' and r.amount>0 and fog.render_known(0,r.p):draw_circle(Vector2(23,755)+r.p/WORLD*Vector2(200,125),3 if r.get('zone','')=='RICH' else 2,Color('#ffe075'))
 for b in buildings:
  if b.team!=0 and not fog.render_sees(0,b.p):continue
  draw_circle(Vector2(23,755)+b.p/WORLD*Vector2(200,125),3,Color('#67cff5') if b.team==0 else Color('#ff7664'))
 for u in units:
  if u.team!=0 and not fog.render_sees(0,u.p):continue
  draw_circle(Vector2(23,755)+u.p/WORLD*Vector2(200,125),1.5,Color('#b8f1ff') if u.team==0 else Color('#ffb28b'))
 fog.draw_minimap()
 draw_rect(Rect2(Vector2(23,755)+(cam+Vector2(0,72))/WORLD*Vector2(200,125),field_rect().size/WORLD*Vector2(200,125)),Color('#ffe7ad'),false,1)
func demo_step():
 if not demo_started:
  demo_started=true
  for i in range(4):units[i].job=resources[0] if i<2 else resources[-1]
 if time>2 and wave==0:
  wave=-1
  var b=entity('Barracks',Vector2(620,650));buildings.append(b)
  buildings.append(entity('House1',Vector2(540,430)))
  buildings.append(entity('House1',Vector2(750,430)))
  for i in range(7):
   var u=entity('Archer' if i%3==0 else 'Warrior',Vector2(700+i*25,680));u.goal=Vector2(1350,680);units.append(u)
  for i in range(5):
   var u=entity('Warrior',Vector2(1450+i*30,680),1);u.goal=Vector2(980,680);units.append(u)
  cam=Vector2(150,220)
 if time>7 and not capture_done:
  capture_done=true
  get_viewport().get_texture().get_image().save_png('res://captures/gameplay.png')
  print('CAPTURE PASS: actual gameplay frame, units=',units.size(),' gathered=',gathered)
 if time>20:get_tree().quit()
func self_test():
 ai_enabled=false
 var worker=units[0];worker.job=resources[0]
 var before=gold
 for i in range(2400):_process(1.0/60)
 assert(gold>before,'Gathering must return resources to town center')
 var b=entity('Barracks',Vector2(620,650));buildings.append(b)
 var h=entity('House1',Vector2(630,420));buildings.append(h)
 var n=units.size();train('Warrior',b)
 for i in range(600):_process(1.0/60)
 assert(units.size()>n,'Training must produce a unit')
 assert(capacity()==10,'House must expand population')
 var enemy=entity('Warrior',Vector2(750,680),1);units.append(enemy)
 var ally=units[-2];ally.p=Vector2(730,680);ally.target=enemy
 for i in range(180):_process(1.0/60)
 assert(enemy.hp<enemy.max,'Combat must deal damage')
 reset()
 resources.clear()
 selected=[units[0]];build_mode='House1'
 place_building(Vector2(580,650))
 assert(wood==220,'Placement must spend wood')
 var site=buildings[-1]
 for i in range(1500):_process(1.0/60)
 assert(site.progress>=1,'Worker must reach and construct house')
 assert(capacity()==10,'Constructed house must add population')
 var enemy_home=buildings.filter(func(v):return v.team==1 and v.kind=='Castle')[0]
 damage(enemy_home,2000);_process(0.016)
 assert(outcome=='VICTORY','Town center destruction must finish match')
 reset()
 assert(outcome=='' and population()==4 and gold==300,'Restart must restore fresh match')
 print('SELF TEST PASS: gather-return, spending, training, population, combat, worker construction, victory, restart')
 get_tree().quit()

func setup_review():
 ai_enabled=false
 units.clear();selected.clear();raid=999;cam=Vector2(320,220)
 buildings.append(entity('Barracks',Vector2(850,650)))
 buildings.append(entity('House1',Vector2(450,400)))
 buildings.append(entity('House1',Vector2(650,400)));nav_dirty=true
 for i in range(12):units.append(entity('Warrior' if i%3 else 'Archer',Vector2(650+(i%4)*32,620+(i/4)*32)))
 selected=units.duplicate();refresh_commands()
 order(Vector2(1410,680),null)
 tell('01 / MOVE — 12 units navigate around the barracks and cross the bridge');note_timer=15
func review_tick():
 if time>13 and review_step==0:
  review_step=1
  var crossed=0
  for u in selected:
   if u.p.x>1320:crossed+=1
  print('STAGE1 CROSSING CHECK: ',crossed,' / ',selected.size())
  for i in range(5):
   var u=entity('Warrior',Vector2(1560+(i%3)*35,660+(i/3)*35),1);units.append(u)
  order(Vector2(1590,680),null,'attack_move')
  tell('02 / ATTACK MOVE — acquire enemies along the route');note_timer=6
 if time>18 and review_step==1:
  review_step=2;order(Vector2(940,680),null)
  tell('03 / RETREAT — movement overrides combat immediately');note_timer=10
 if time>27 and review_step==2:
  review_step=3;stop_selected();tell('04 / STOP — hold position, no automatic re-engagement');note_timer=5
  var safe=true
  for u in selected:
   if u.p.x>1100 or u.target!=null:safe=false
  print('STAGE1 RETREAT CHECK: ',safe,' survivors=',selected.size())
 if time>30:
  get_viewport().get_texture().get_image().save_png('res://captures/stage1.png')
  get_tree().quit()

func create_formation(members,p,mode):
 if nav_dirty:rebuild_nav()
 var center=Vector2.ZERO
 for u in members:center+=u.p
 center/=members.size()
 var forward=center.direction_to(p)
 if forward.length()<0.1:forward=Vector2.RIGHT
 var columns=int(ceil(sqrt(members.size())))
 # Assign nearby slots rather than reversing the entire roster on a turn.
 var pool=members.duplicate()
 var assigned=[]
 for i in range(members.size()):
  var slot=center+formation_offset(i,members.size(),columns,forward)
  var rank={'Warrior':0,'Cavalry':0,'Spearman':1,'Pawn':1,'Archer':2,'Catapult':3}
  var best=pool[0]
  for candidate in pool:
   var priority=rank.get(candidate.kind,1);var current=rank.get(best.kind,1)
   if priority<current or (priority==current and candidate.p.distance_squared_to(slot)<best.p.distance_squared_to(slot)):best=candidate
  assigned.append(best);pool=pool.filter(func(item):return not is_same(item,best))
 members=assigned
 var id=formations.size()
 var leader=entity('Pawn',center)
 leader.path=nav.get_point_path(nearest_cell(center),nearest_cell(p))
 formations.append({'id':id,'members':members,'anchor':leader,'destination':p,'forward':forward,'columns':columns,'width':1.0,'mode':mode})
 for u in members:u.formation=id
func formation_offset(index,count,columns,forward):
 var rows=int(ceil(float(count)/columns))
 var row=int(index/columns)
 var row_count=min(columns,count-row*columns)
 var side=Vector2(-forward.y,forward.x)
 return side*(float(index%columns)-(row_count-1)*0.5)*46+forward*((rows-1)*0.5-row)*46
func update_formations(dt):
 for f in formations:
  var members=f.members.filter(func(u):return u.hp>0 and u.formation==f.id)
  if members.is_empty():continue
  # Attack-move is a squad order: nearby idle members support contact.
  var contact=null
  for u in members:
   if u.target!=null and u.target.hp>0 and fog.sees(u.team,u.target.p):contact=u.target;break
  if f.mode=='attack_move' and contact!=null:
   for u in members:
    if u.target==null and u.p.distance_to(contact.p)<400:u.target=contact
  # Resume from the engagement, not the old pre-combat anchor behind the army.
  if f.mode=='attack_move' and contact==null and f.get('was_fighting',false):
   var center=Vector2.ZERO
   for u in members:center+=u.p
   center/=members.size()
   if not nav_clear(center):center=Vector2(nearest_cell(center))*20+Vector2(10,10)
   f.anchor.p=center;f.anchor.path=PackedVector2Array()
   for u in members:u.goal=u.p;u.slot_velocity=Vector2.ZERO
  f['was_fighting']=contact!=null
  var lag=0.0
  var fighting=false
  for u in members:
   lag=max(lag,u.p.distance_to(u.goal))
   if u.target!=null and u.target.hp>0 and fog.sees(u.team,u.target.p):fighting=true
  # Shared anchor speed lets the formation settle and regroup after obstacles.
  var pace=clamp((130.0-lag)/80.0,0.0,1.0)
  if not fighting:move_unit(f.anchor,f.destination,dt*(0.44 if members.any(func(u):return u.kind=='Catapult') else (1.10 if members.all(func(u):return u.kind=='Cavalry') else 0.62))*pace,8)
  # Keep each soldier's rank and file stable; squeeze laterally without
  # switching row indices and making soldiers cross one another.
  var bridge_distance=abs(f.anchor.p.x-WORLD.x/2)
  var desired_width=lerp(0.46,1.0,clamp((bridge_distance-180.0)/120.0,0.0,1.0))
  f.width=move_toward(f.width,desired_width,dt*0.7)
  var side=Vector2(-f.forward.y,f.forward.x)
  for i in range(members.size()):
   var u=members[i]
   var offset=formation_offset(i,members.size(),f.columns,f.forward)
   offset-=side*offset.dot(side)*(1.0-f.width)
   var slot=f.anchor.p+offset
   if not nav_clear(slot):slot=Vector2(nearest_cell(slot))*20+Vector2(10,10)
   u.slot_velocity=(slot-u.goal)/max(dt,0.0001)
   u.goal=slot
func setup_formation_video():
 ai_enabled=false
 units.clear();selected.clear();formations.clear();raid=999;cam=Vector2(320,220)
 buildings.append(entity('House1',Vector2(450,400)))
 buildings.append(entity('House1',Vector2(650,400)));nav_dirty=true
 for i in range(12):units.append(entity('Archer' if i>=8 else 'Warrior',Vector2(750+(i%4)*46,600+(i/4)*46)))
 selected=units.duplicate();refresh_commands()
 order(Vector2(960,680),null)
 tell('01 / FORM UP — stable slots, no friendly pushing');note_timer=9
func formation_video_tick():
 if time>8 and formation_phase==0:
  formation_phase=1;order(Vector2(1490,680),null)
  tell('02 / CROSS — smoothly narrow spacing, preserve ranks');note_timer=20
 if time>27 and formation_phase==1:
  formation_phase=2
  var crossed=0
  var error=0.0
  for u in selected:
   if u.p.x>1308:crossed+=1
   error=max(error,u.p.distance_to(u.goal))
  print('FORMATION CROSS: ',crossed,'/12 max slot error=',error)
  get_viewport().get_texture().get_image().save_png('res://captures/formation-smooth-cross.png')
  order(Vector2(940,680),null)
  tell('03 / RETURN — nearby slot assignment, no destination overlays');note_timer=20
 if time>47:
  var error=0.0
  for u in selected:error=max(error,u.p.distance_to(u.goal))
  print('FORMATION RETURN: max slot error=',error)
  get_viewport().get_texture().get_image().save_png('res://captures/formation-smooth-return.png')
  get_tree().quit()

func setup_combat_video():
 ai_enabled=false
 units.clear();buildings.clear();resources.clear();formations.clear();shots.clear();selected.clear()
 nav_dirty=true;raid=999;cam=Vector2(0,100)
 var sword=entity('Warrior',Vector2(250,350));var victim=entity('Warrior',Vector2(470,350),1)
 victim.mode='stop';victim.hp=1000;victim.max=1000
 units.append_array([sword,victim]);selected=[sword];order(victim.p,victim)
 var archer=entity('Archer',Vector2(260,580));var runner=entity('Warrior',Vector2(570,580),1)
 runner.mode='stop';runner.hp=1000;runner.max=1000
 units.append_array([archer,runner]);selected=[archer];order(runner.p,runner)
 var barracks=entity('Barracks',Vector2(940,460),1);buildings.append(barracks)
 var siege=entity('Warrior',Vector2(680,460));units.append(siege);selected=[siege];order(barracks.p,barracks)
 selected=[sword,archer,siege];refresh_commands()
 tell('RANGE CHECK / Top: sword   Bottom: archer   Right: building edge');note_timer=9
func combat_video_tick():
 if time>7 and combat_phase==0:
  combat_phase=1
  get_viewport().get_texture().get_image().save_png('res://captures/stage1-combat-range.png')
  units[1].mode='move';units[1].goal=Vector2(760,350)
  units[3].mode='move';units[3].goal=Vector2(860,660)
  tell('MOVING TARGETS / Melee closes distance; arrows fly to the launch-time position');note_timer=8
 if time>14 and combat_phase==1:
  combat_phase=2
  selected=units.filter(func(u):return u.team==0)
  order(Vector2(330,460),null)
  tell('RETREAT / Movement cancels attack wind-up immediately');note_timer=7
 if time>20 and combat_phase==2:
  combat_phase=3;stop_selected();tell('STOP / No new attacks or automatic chase');note_timer=5
 if time>24:
  print('COMBAT VIDEO: ',combat_events.size(),' attacks checked')
  for event in combat_events:assert(event.gap<=event.limit+0.01)
  get_viewport().get_texture().get_image().save_png('res://captures/stage1-combat-review.png')
  get_tree().quit()

func update_economy_hud():
 if queue_row==null:return
 var b=selected[0] if not selected.is_empty() and contains_entity(buildings,selected[0]) else null
 var signature='none' if b==null else str(b.p)+str(b.queue)+str(b.progress>=1)
 if signature!=queue_signature:
  queue_signature=signature
  for child in queue_row.get_children():queue_row.remove_child(child);child.queue_free()
  if b!=null:
   for i in range(b.queue.size()):
    var index=i
    var card=Button.new();card.custom_minimum_size=Vector2(52,50)
    card.add_theme_font_size_override('font_size',13);card.add_theme_stylebox_override('normal',style(Color('#3d4b43')))
    icon_hud.decorate(card,b.queue[i],NAMES[b.queue[i]])
    card.tooltip_text+='\nClick to cancel. Full resource refund; training progress is lost.'
    card.pressed.connect(func():economy.cancel(b,index));queue_row.add_child(card)
  refresh_commands()
 production_info.text=''
 if b!=null and b.kind in ['Castle','Barracks','Workshop']:
  if b.progress<1:production_info.text='Construction %d%% · training locked'%int(b.progress*100)
  elif b.queue.is_empty():production_info.text='Queue 0/5 · Right-click ground, friendly unit or resource to rally'
  else:
   var remaining=max(0,economy.duration(b.queue[0])-b.train)
   production_info.text='%s: %.1fs · Queue %d/5 · Click card: cancel + full refund'%[NAMES[b.queue[0]],remaining,b.queue.size()]
   if population()>capacity():production_info.text='POPULATION BLOCKED · Build a House to resume training'
func setup_economy_video():
 ai_enabled=false
 reset();raid=999;cam=Vector2(0,120);preview_override=true
 resources.clear()
 resources.append({'kind':'gold','p':Vector2(210,750),'amount':9})
 resources.append({'kind':'gold','p':Vector2(310,790),'amount':500})
 resources.append({'kind':'wood','p':Vector2(190,380),'amount':500})
 resources.append({'kind':'wood','p':Vector2(250,370),'amount':500})
 selected=[units[0]];order(resources[0].p,resources[0])
 selected=[units[1]];order(resources[2].p,resources[2])
 selected=[units[0],units[1]];refresh_commands()
 tell('01 / ECONOMY — workers gather, return cargo, and find the next deposit');note_timer=8
func economy_video_tick():
 if time>3 and economy_phase==0:
  economy_phase=1;selected=[units[2]];build_mode='House1';preview_position=buildings[0].p;refresh_commands()
  tell('02 / PLACEMENT — red foundation: blocked by the Town Center');note_timer=3
 if time>5 and economy_phase==1:
  economy_phase=2;preview_position=Vector2(620,480)
  tell('Green foundation: valid site · House costs 80 wood');note_timer=3
 if time>7 and economy_phase==2:
  economy_phase=3;economy_house=place_building(preview_position)
  tell('03 / CONSTRUCTION — workers travel to site; housing unlocks when complete');note_timer=7
 if time>10 and economy_phase==3:
  economy_phase=4;selected=[units[3]];build_mode='Barracks';preview_position=Vector2(780,650);refresh_commands()
 if time>12 and economy_phase==4:
  economy_phase=5;economy_barracks=place_building(preview_position);selected=[economy_barracks];refresh_commands()
  tell('Barracks under construction · training is unavailable until complete');note_timer=9
 if time>29 and economy_phase==5 and economy_barracks.progress>=1:
  economy_phase=6;selected=[economy_barracks];order(Vector2(970,650),null)
  train('Warrior',economy_barracks);train('Archer',economy_barracks);train('Warrior',economy_barracks)
  tell('04 / PRODUCTION — paid queue, reserved population, visible rally flag');note_timer=6
  get_viewport().get_texture().get_image().save_png('res://captures/stage2-production.png')
 if time>32 and economy_phase==6:
  economy_phase=7;economy.cancel(economy_barracks,2)
 if time>34 and economy_phase==7:
  economy_phase=8;economy.cancel(economy_barracks,0);train('Warrior',economy_barracks)
  tell('05 / CANCEL — full refund; cancelling active training resets its progress');note_timer=7
 if time>43 and economy_phase==8:
  economy_phase=9;tell('06 / RALLY — new troops leave the barracks and move to the flag');note_timer=12
 if time>56:
  print('STAGE2 VIDEO: gathered=',gathered,' trained=',trained,' house=',economy_house.progress,' barracks=',economy_barracks.progress)
  assert(economy_house.progress>=1 and economy_barracks.progress>=1 and trained>=2 and gathered>0)
  get_viewport().get_texture().get_image().save_png('res://captures/stage2-complete.png')
  get_tree().quit()

func setup_map_video():
 ai_enabled=false;cam=Vector2(520,0);map_phase=0
 buildings.append(entity('House1',Vector2(620,480)));nav_dirty=true
 map_squad=[]
 for i in range(6):
  var u=entity('Archer' if i>3 else 'Warrior',Vector2(850+(i%3)*45,270+int(i/3)*45))
  units.append(u);map_squad.append(u)
 selected=map_squad.duplicate();refresh_commands()
 var mine=resources.filter(func(r):return r.get('zone','')=='RICH' and r.p==Vector2(1470,410))[0]
 var worker=units.filter(func(u):return u.team==1 and u.kind=='Pawn')[0]
 worker.p=Vector2(1510,450);issue_order([worker],mine.p,mine)
func map_video_tick():
 message.text='MAP REVIEW | Home: 900 gold | Rich mine: 2600 | North bridge bypasses the main crossing'
 if time>3 and map_phase==0:
  issue_order(map_squad,Vector2(1510,290),null,'move');map_phase=1
 if time>17 and map_phase==1:
  issue_order(map_squad,Vector2(1470,440),null,'attack_move');map_phase=2
 if time>26 and map_phase==2:
  issue_order(map_squad,Vector2(950,690),null,'move');map_phase=3
 if time>28:cam=cam.lerp(Vector2(520,200),0.04)
 if time>46:
  print('MAP VIDEO: north flank, resource raid, main crossing return; kills=',kills,' returned=',map_squad.all(func(u):return u.p.x<1100))
  get_tree().quit()

func notify_web_ready():
 await RenderingServer.frame_post_draw
 JavaScriptBridge.eval("window.dispatchEvent(new Event('little-knights-ready'))",true)

func web_loading_stage(message):
 if OS.has_feature("web"):
  JavaScriptBridge.eval("window.dispatchEvent(new CustomEvent('little-knights-loading',{detail:"+JSON.stringify(message)+"}))",true)

func follow_step(u,dt):
 var leader=u.get('follow_unit')
 if leader==null or leader.hp<=0 or not contains_entity(units,leader):
  repairs.clear(u)
  u['follow_unit']=null;u.mode='guard';u.goal=u.p;u.path=PackedVector2Array();return
 var destination=leader.p+u.get('follow_offset',Vector2(0,65))
 var gap=u.p.distance_to(destination)
 if u.get('follow_wait',false) and gap<32:
  u.moving=false;return
 if gap<10:
  u['follow_wait']=true;u.moving=false;u.path=PackedVector2Array();return
 u['follow_wait']=false;u.goal=destination
 move_unit(u,destination,dt,10)
