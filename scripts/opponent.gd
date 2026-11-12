extends RefCounted
var g
var defense
var retreat
const FIRST_SORTIE=150.0
var attack_history=[]
var clock=0.0
var state='Building economy'
var squads=[]
var flank_attacks=0
var attacks=0
var last_attack=-100.0
func _init(game):g=game;defense=preload("res://scripts/defense.gd").new(g);retreat=preload("res://scripts/retreat.gd").new(g)
func reset():defense.reset();retreat.reset();attack_history.clear();squads.clear();flank_attacks=0;clock=0.0;state='Building economy';attacks=0;last_attack=-100.0
func owned(kind):return g.buildings.filter(func(b):return b.team==1 and b.hp>0 and b.kind==kind)
func build(kind,workers):
 if g.random_map_enabled:
  var hy=g.random_map.home_position.y
  for y in [hy+270,hy-220,hy+430,hy-430]:
   for x in [g.WORLD.x-650,g.WORLD.x-820,g.WORLD.x-450,g.WORLD.x-1000]:
    var p=Vector2(x,y)
    if g.economy.placement_reason(kind,p,[workers[0]])=='':return g.economy.place(kind,p,[workers[0]])
  return null
 # Search legal foundations using exactly the player's placement checks.
 for y in [920,540,1080,380,1220]:
  for x in [1920,1770,2100,2240,1620]:
   var p=Vector2(x,y)
   if g.economy.placement_reason(kind,p,[workers[0]])=='':return g.economy.place(kind,p,[workers[0]])
 return null
func tick(dt):
 retreat.tick(dt)
 for squad in squads:squad.members=squad.members.filter(func(u):return not u.get("retreating",false))
 defense.tick(dt)
 clock-=dt
 if clock>0:return
 clock=1.0
 if defense.active:
  for squad in squads:squad.members=squad.members.filter(func(u):return not g.contains_entity(defense.defenders,u))
 if not defense.active:tick_routes()
 var castles=owned('Castle')
 if castles.is_empty():return
 var home=castles[0]
 var workers=g.units.filter(func(u):return u.team==1 and u.hp>0 and u.kind=='Pawn' and not u.get('fleeing',false))
 var army=g.units.filter(func(u):return u.team==1 and u.hp>0 and u.kind!='Pawn')
 var unfinished=g.buildings.filter(func(b):return b.team==1 and b.hp>0 and b.progress<1)
 # Replace lost workers, but reserve the same population and pay the same price.
 if g.units.filter(func(u):return u.team==1 and u.hp>0 and u.kind=='Pawn').size()+home.queue.size()<8 and home.queue.is_empty() and (not defense.home_alert or workers.size()<4 or g.enemy_money.x>=130):g.economy.train('Pawn',home)
 if not workers.is_empty():
  if not unfinished.is_empty():
   var site=unfinished[0]
   if not workers.any(func(u):return is_same(u.job,site)):g.issue_order([workers[0]],site.p,site)
  elif g.capacity(1)-g.population(1)<=2 and g.capacity(1)<40:build('House1',workers)
  elif owned('Barracks').is_empty():build('Barracks',workers)
  elif g.time>=50 and owned('Tower').is_empty() and army.size()>=4 and g.enemy_money.y>=200:build('Tower',workers)
  elif not defense.active and g.time>=120 and owned('Smith').is_empty() and army.size()>=6 and g.enemy_money.y>=200:build('Smith',workers)
  elif not defense.active and g.time>=180 and owned('Workshop').is_empty() and army.size()>=8 and g.enemy_money.y>=280:build('Workshop',workers)
  elif g.time>=360 and owned('Barracks').size()<2 and g.enemy_money.x>=200:build('Barracks',workers)
  var miners=workers.filter(func(u):return u.job!=null and u.job.get('kind','')=='gold').size()
  for u in workers:
   if u.job!=null or u.target!=null:continue
   var kind='gold' if miners<5 else 'wood'
   var resource=g.economy.nearby_resource(u,kind,home.p)
   if resource==null and kind=='gold':
    var deposits=g.resources.filter(func(r):return r.kind=='gold' and r.amount>0 and r.p.x>g.WORLD.x/2+120)
    deposits.sort_custom(func(a,b):return u.p.distance_to(a.p)<u.p.distance_to(b.p))
    for r in deposits:
     if not g.nav.get_point_path(g.nearest_cell(u.p),g.nearest_cell(r.p)).is_empty():resource=r;break
   if resource!=null:
    g.issue_order([u],resource.p,resource)
    if kind=='gold':miners+=1
 if not defense.home_alert:g.economy.plan_expansion(1,workers)
 for b in owned('Barracks'):
  b.rally=home.p+Vector2(-180,100) if defense.active else (g.supply.planner.staging(1) if g.supply.enabled else Vector2(1800,760))
  if b.progress>=1 and b.queue.size()<1 and army.size()<16:
   var roster=['Warrior','Spearman','Archer']
   if owned('Smith').any(func(f):return f.progress>=1):roster.append('Cavalry')
   var kind=roster[int(b.get('spawned',0))%roster.size()]
   if not g.economy.train(kind,b) and g.enemy_money.x>=55:g.economy.train('Spearman',b)
 for tower in owned('Tower'):
  if not defense.active and army.size()>=6 and g.time>=180 and g.enemy_money.x>=240 and g.enemy_money.y>=160:
   var key=g.tower_upgrades.branch(tower)
   if key=='':
    var visible=g.units.filter(func(u):return u.team==0 and u.hp>0 and g.fog.sees(1,u.p))
    key='cannon' if visible.any(func(u):return u.kind in ['Cavalry','Catapult']) else 'arrow'
   g.tower_upgrades.upgrade(tower,key)
 for forge in owned('Smith'):
  if not defense.active and army.size()>=6 and forge.progress>=1 and forge.research=='' and g.enemy_money.x>=240:
   var key='attack' if g.technology.levels[1].attack<=g.technology.levels[1].armor else 'armor'
   g.technology.research(forge,key)
 for factory in owned('Workshop'):
  if factory.progress>=1 and factory.queue.is_empty() and army.filter(func(u):return u.kind=='Catapult').size()<2:g.train('Catapult',factory)
 if defense.active and (defense.home_alert or not g.supply.enabled):
  state='Defending base' if defense.home_alert else 'Protecting workers'
  return
 if g.supply.enabled:
  g.supply.plan(1);state='Contesting river / north supply';return
 var ready=army.filter(func(u):return u.p.x>1600 and u.target==null and not u.get("retreating",false) and g.time>=u.get("retreat_cooldown",0))
 var attack_size=3 if g.time<300 else (5 if g.time<480 else 7)
 if g.time>=FIRST_SORTIE and ready.size()>=attack_size+2 and g.time-last_attack>=(70 if g.time<300 else 60):
  var squad=ready.slice(0,attack_size)
  var guarded=g.units.any(func(u):return u.team==0 and u.hp>0 and g.fog.sees(1,u.p) and u.kind!='Pawn' and u.p.distance_to(Vector2(1080,690))<320) or g.buildings.any(func(b):return b.team==0 and b.hp>0 and g.fog.sees(1,b.p) and b.kind=='Tower' and b.p.distance_to(Vector2(1080,690))<360)
  send_squad(squad,guarded or attacks%2==1)
  attacks+=1;last_attack=g.time
  attack_history.append({'time':g.time,'size':squad.size(),'flank':guarded or (attacks-1)%2==1})
  g.tell('Red army is marching. Its workers and barracks supply reinforcements.')
 state='Attack %d underway; retaining two defenders'%attacks if attacks>0 else 'Gathering / building / assembling'

func send_squad(members,flank):
 var points=[Vector2(1490,290),Vector2(950,290),Vector2(360,600)] if flank else [Vector2(360,600)]
 if flank:flank_attacks+=1
 squads.append({'members':members,'points':points,'index':0})
 g.issue_order(members,points[0],null,'attack_move')
func tick_routes():
 for squad in squads:
  var alive=squad.members.filter(func(u):return u.hp>0 and not u.get("retreating",false) and not g.contains_entity(defense.defenders,u))
  if alive.is_empty() or squad.index>=squad.points.size()-1:continue
  var arrived=alive.all(func(u):return u.target==null and u.p.distance_to(squad.points[squad.index])<125)
  if arrived:
   squad.index+=1
   g.issue_order(alive,squad.points[squad.index],null,'attack_move')
 squads=squads.filter(func(s):return s.members.any(func(u):return u.hp>0) and s.index<s.points.size()-1)
