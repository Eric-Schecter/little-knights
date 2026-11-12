extends RefCounted
const CAPTURE_SECONDS=8.0
const RADIUS=108.0
var g
var enabled=true
var points=[]
var scores=[0.0,0.0]
var income=[Vector2i.ZERO,Vector2i.ZERO]
var captures=[0,0]
var events=[]
var next_plan=[0.0,0.0]
var map_buttons=[]
var planner
func _init(game):g=game;planner=preload('res://scripts/army_plan.gd').new(g)
func reset():
 planner.reset()
 scores=[0.0,0.0];income=[Vector2i.ZERO,Vector2i.ZERO];captures=[0,0];events=[];next_plan=[0.0,0.0]
 points=[]
 for spec in [[('MAIN CAMP' if g.map_style=='plains' else 'RIVER CAMP'),Vector2(g.WORLD.x/2,(g.CROSSINGS[0].x+g.CROSSINGS[0].y)/2)],['NORTH SUPPLY',Vector2(g.WORLD.x/2,(g.CROSSINGS[1].x+g.CROSSINGS[1].y)/2)]]:
  points.append({'name':spec[0],'p':spec[1],'owner':-1,'claim':-1,'progress':0.0,'contested':false,'blocked':false,'income_clock':0.0})
 if not enabled:return
 for team in range(2):
  var home=g.buildings.filter(func(b):return b.team==team and b.kind=='Castle')[0]
  var sign_x=1 if team==0 else -1
  for spec in [['Barracks',Vector2(sign_x*220,130)],['House1',Vector2(sign_x*230,-170)],['House1',Vector2(-sign_x*120,-170)]]:
   var p=home.p+spec[1]
   g.resources=g.resources.filter(func(r):return r.p.distance_to(p)>125)
   g.buildings.append(g.entity(spec[0],p,team))
  for i in range(4):
   var u=g.entity('Archer' if i==3 else 'Warrior',Vector2((g.WORLD.x/2-420) if team==0 else (g.WORLD.x/2+420),(g.CROSSINGS[0].x+g.CROSSINGS[0].y)/2-68 if g.random_map_enabled else 620)+Vector2((i%2)*46*(1 if team==0 else -1),int(i/2)*46),team)
   g.resources=g.resources.filter(func(r):return r.p.distance_to(u.p)>55)
   g.units.append(u)
  var workers=g.units.filter(func(u):return u.team==team and u.kind=='Pawn')
  for i in range(workers.size()):
   var sources=g.resources.filter(func(r):return r.kind==('gold' if i<2 else 'wood'))
   sources.sort_custom(func(a,b):return a.p.distance_to(home.p)<b.p.distance_to(home.p))
   if not sources.is_empty():g.issue_order([workers[i]],sources[0].p,sources[0])
 g.selected=g.units.filter(func(u):return u.team==0 and u.kind!='Pawn')
 g.nav_dirty=true
 g.tell('Destroy the enemy Town Center to win. Camps supply bonus resources.')
func tick(dt):
 if not enabled or g.outcome!='':return
 for index in range(points.size()):
  var point=points[index];var present=[false,false]
  for u in g.units:
   if u.hp>0 and u.kind!='Pawn' and u.p.distance_to(point.p)<=RADIUS:present[u.team]=true
  point.contested=present[0] and present[1]
  point.blocked=point.contested or (point.owner>=0 and present[1-point.owner])
  var claimant=0 if present[0] else (1 if present[1] else -1)
  if not point.contested and claimant>=0 and claimant!=point.owner:
   if point.claim!=claimant:point.claim=claimant;point.progress=0.0
   point.progress+=dt
   if point.progress>=CAPTURE_SECONDS:
    if point.owner>=0:
     point.owner=-1
     events.append({'time':g.time,'event':'neutralized','point':index,'team':claimant})
    else:
     point.owner=claimant;captures[claimant]+=1
     events.append({'time':g.time,'event':'captured','point':index,'team':claimant})
     g.tell(('%s captured '%('Blue' if claimant==0 else 'Red'))+point.name)
    point.progress=0.0;point.income_clock=0.0
  elif not point.contested:
   point.progress=maxf(0,point.progress-dt*2)
   if point.progress==0:point.claim=-1
  if point.owner<0 or point.blocked:continue
  point.income_clock+=dt
  while point.income_clock>=10:
   point.income_clock-=10
   var reward=Vector2i(12,6)
   g.economy.credit(point.owner,reward);income[point.owner]+=reward
func order_to(index):
 var army=g.selected.filter(func(u):return g.contains_entity(g.units,u) and u.team==0 and u.kind!='Pawn')
 if army.is_empty():g.tell('Select soldiers first (F selects your army).');return
 g.issue_order(army,points[index].p,null,'attack_move')
 g.tell('Capture with soldiers: 8s neutral / 16s enemy. Contested points stop paying.')
func build_ui():
 if not enabled:return
 for i in range(2):
  var index=i
  var button=g.button('R' if i==0 else 'N',g.minimap_rect().position+points[i].p/g.WORLD*Vector2(200,125)-Vector2(9,9),Vector2(18,18),func():g.cam=(points[index].p-Vector2(720,350)).clamp(Vector2(0,-72),g.camera_limit()))
  button.add_theme_font_size_override('font_size',12)
  button.tooltip_text=points[i].name+' (public objective; click to view)'
  map_buttons.append(button)
func update_ui():
 if not enabled:return
 for i in range(map_buttons.size()):
  map_buttons[i].position=g.minimap_rect().position+points[i].p/g.WORLD*Vector2(200,125)-Vector2(9,9)
  map_buttons[i].modulate=Color('#ead7ac') if points[i].owner<0 else (Color('#70d7ef') if points[i].owner==0 else Color('#f7a08c'))
func draw_world():
 if not enabled:return
 for point in points:
  var c=Color('#cfbd8c') if point.owner<0 else (Color('#65c9ed') if point.owner==0 else Color('#e88d77'))
  g.draw_arc(point.p,RADIUS,0,TAU,64,Color(c,0.45),2,true)
  g.draw_line(point.p+Vector2(0,9),point.p+Vector2(0,-43),Color('#534b37'),4,true)
  g.draw_colored_polygon(PackedVector2Array([point.p+Vector2(2,-42),point.p+Vector2(30,-34),point.p+Vector2(2,-24)]),c)
  if point.progress>0:g.draw_arc(point.p,24,-PI/2,-PI/2+TAU*point.progress/CAPTURE_SECONDS,32,Color('#fff0b5'),4,true)
  g.draw_string(ThemeDB.fallback_font,point.p+Vector2(-60,46),'CONTESTED' if point.contested else ('CAPTURING' if point.progress>0 else point.name),HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color('#fff0d2'))
func plan(team):
 if not enabled or g.time<next_plan[team]:return
 next_plan[team]=g.time+2
 planner.plan(team)
