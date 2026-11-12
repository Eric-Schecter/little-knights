# Review-only conservative player: every action uses normal economy and orders.
extends RefCounted
var g
var clock=0.0
var assaults=0
var last_assault=-100.0
var expansions=-1.0
var first_contact=-1.0
var reported_minute=-1
var camp_events=[]
var seen_camps={}
func _init(game):g=game
func owned(kind):return g.buildings.filter(func(b):return b.team==0 and b.hp>0 and b.kind==kind)
func build(kind,workers):
 var sites=[Vector2(620,650),Vector2(540,350)] if kind=='Tower' else [Vector2(620,480),Vector2(800,900),Vector2(620,1050),Vector2(800,1150),Vector2(950,900),Vector2(460,1100),Vector2(800,480),Vector2(450,900)]
 if g.random_map_enabled:
  sites=[]
  var hy=g.WORLD.y*0.45
  for y in [hy+270,hy-220,hy+430,hy-430]:
   for x in [650,820,450,1000]:sites.append(Vector2(x,y))
 if kind!='Tower' and not g.random_map_enabled:
  for y in [250,400,600,850,1050,1200]:
   for x in [260,450,650,850,1000]:sites.append(Vector2(x,y))
 for p in sites:
  if g.economy.placement_reason(kind,p,[workers[0]])=='':return g.economy.place(kind,p,[workers[0]])
 return null
func tick(dt):
 clock-=dt
 if clock>0:return
 clock=1.0
 for b in g.buildings:
  if b.kind!='Depot':continue
  var key=str(b.team)+str(b.p)+str(b.progress>=1)
  if not seen_camps.has(key):
   seen_camps[key]=true;camp_events.append({'time':g.time,'team':b.team,'complete':b.progress>=1,'position':b.p})
   print('EXPANSION EVENT ',camp_events[-1])
 var minute=int(g.time/60)
 if g.match_video and minute!=reported_minute:
  reported_minute=minute
  print('MATCH PROGRESS ',int(g.time),'s retreats=',g.opponent.retreat.retreats,' emergency_returns=',g.opponent.retreat.emergency_returns,' assaults=',assaults)
 if owned('Castle').is_empty():return
 var home=owned('Castle')[0]
 var workers=g.units.filter(func(u):return u.team==0 and u.kind=='Pawn' and u.hp>0)
 var army=g.units.filter(func(u):return u.team==0 and u.kind!='Pawn' and u.hp>0)
 var unfinished=g.buildings.filter(func(b):return b.team==0 and b.hp>0 and b.progress<1)
 if workers.size()+home.queue.size()<8 and home.queue.is_empty():g.train('Pawn',home)
 if not workers.is_empty():
  if not unfinished.is_empty():
   var site=unfinished[0]
   if not workers.any(func(u):return is_same(u.job,site)):g.issue_order([workers[0]],site.p,site)
  elif g.capacity()-g.population()<=2 and g.capacity()<40:build('House1',workers)
  elif owned('Barracks').is_empty():build('Barracks',workers)
  elif g.time>110 and owned('Smith').is_empty() and g.wood>=180:build('Smith',workers)
  elif g.time>165 and owned('Workshop').is_empty() and g.wood>=260:build('Workshop',workers)
  elif g.time>95 and owned('Tower').size()<1:build('Tower',workers)
  elif g.time>300 and owned('Barracks').size()<2:build('Barracks',workers)
  var miners=workers.filter(func(u):return u.job!=null and u.job.get('kind','')=='gold').size()
  for u in workers:
   if u.job!=null or u.target!=null:continue
   var kind='gold' if miners<5 else 'wood'
   var r=g.economy.nearby_resource(u,kind,home.p)
   if r==null and kind=='gold':
    var mines=g.resources.filter(func(m):return m.kind=='gold' and m.amount>0 and m.p.x<g.WORLD.x/2-120)
    mines.sort_custom(func(a,b):return u.p.distance_to(a.p)<u.p.distance_to(b.p))
    if not mines.is_empty():r=mines[0]
   if r!=null:
    g.issue_order([u],r.p,r)
    if kind=='gold':miners+=1
    if r.get('zone','')=='RICH' and expansions<0:expansions=g.time
 g.economy.plan_expansion(0,workers)
 for b in owned('Barracks'):
  b.rally=g.supply.planner.staging(0) if g.supply.enabled else Vector2(620,600)
  if b.progress>=1 and b.queue.is_empty() and army.size()<(16 if g.supply.enabled else 24):
   var archers=army.filter(func(u):return u.kind=='Archer').size()
   var cavalry_ready=owned('Smith').any(func(f):return f.progress>=1)
   g.train('Cavalry' if cavalry_ready and g.trained%4==3 else ('Spearman' if g.trained%4==2 else ('Archer' if archers<army.size()/3 else 'Warrior')),b)
 for forge in owned('Smith'):
  if forge.progress>=1 and forge.research=='' and g.gold>=200:
   var key='attack' if g.technology.levels[0].attack<=g.technology.levels[0].armor else 'armor'
   g.technology.research(forge,key)
 for factory in owned('Workshop'):
  if factory.progress>=1 and factory.queue.is_empty() and army.filter(func(u):return u.kind=='Catapult').size()<2:g.train('Catapult',factory)
 if g.supply.enabled:
  g.supply.plan(0);return
 var intruders=g.units.filter(func(u):return u.team==1 and u.hp>0 and g.fog.sees(0,u.p) and u.p.x<1000)
 if not intruders.is_empty():
  if first_contact<0:first_contact=g.time
  var defenders=army.filter(func(u):return not u.get('review_assault',false) and not u.get('review_defender',false) and u.p.x<1050)
  if not defenders.is_empty():
   var point=Vector2(min(900.0,intruders[0].p.x),intruders[0].p.y)
   g.issue_order(defenders,point,null,'guard')
   for u in defenders:u['review_defender']=true
 # Commit the available army together; home defense cannot overwrite this order.
 var ready=army.filter(func(u):return not u.get('review_assault',false))
 if g.time>=450 and g.time-last_assault>=65 and ready.size()>=9:
  for u in ready:u['review_assault']=true;u['review_defender']=false
  g.issue_order(ready,Vector2(2050,730),null,'attack_move')
  assaults+=1;last_assault=g.time
 var enemy_home=g.buildings.filter(func(b):return b.team==1 and b.kind=='Castle' and b.hp>0 and g.fog.sees(0,b.p))
 if not enemy_home.is_empty():
  for u in army:
   if u.get('review_assault',false) and u.p.x>1500 and u.target==null:g.issue_order([u],enemy_home[0].p,enemy_home[0])

func camera():
 if g.supply.enabled and '--observe-match' in OS.get_cmdline_user_args():
  var camps=g.buildings.filter(func(b):return b.kind=='Depot' and b.hp>0)
  var focus=g.supply.points[0].p
  var phase=int(g.time)%48
  if not camps.is_empty() and phase<24:
   var camp=camps[int(g.time/48)%camps.size()];focus=camp.p;g.selected=[camp]
  elif g.time<40:focus=Vector2(380 if phase<20 else g.WORLD.x-380,g.WORLD.y*0.45)
  g.cam=g.cam.lerp((focus-Vector2(680,350)).clamp(Vector2.ZERO,g.camera_limit()),0.12)
  return
 if g.supply.enabled:
  # Blue-side review camera uses only own units/buildings and visible enemies.
  var home=owned('Castle')
  var camps=owned('Depot')
  var fighters=g.units.filter(func(u):return u.team==0 and u.hp>0 and u.kind!='Pawn' and u.target!=null and g.fog.sees(0,u.target.p))
  var focus=g.supply.points[0].p
  var home_under_attack=not home.is_empty() and g.units.any(func(u):return u.team==1 and u.hp>0 and u.kind!='Pawn' and g.fog.sees(0,u.p) and u.p.distance_to(home[0].p)<450)
  if home_under_attack:focus=home[0].p
  elif g.time<20 and not home.is_empty():focus=home[0].p
  elif int(g.time)%48<12 and not camps.is_empty():focus=camps[0].p;g.selected=[camps[0]]
  elif not fighters.is_empty():focus=fighters[0].p
  else:
   var army=g.units.filter(func(u):return u.team==0 and u.hp>0 and u.kind!='Pawn')
   if not army.is_empty():focus=army[0].p
  g.cam=g.cam.lerp((focus-Vector2(680,350)).clamp(Vector2.ZERO,g.camera_limit()),0.06)
  return
 var fighters=g.units.filter(func(u):return u.kind!='Pawn' and u.target!=null and g.fog.sees(0,u.p))
 var focus=Vector2(400,550)
 if not fighters.is_empty():
  focus=Vector2.ZERO
  for u in fighters:focus+=u.p
  focus/=fighters.size()
 elif g.time>450:
  var invaders=g.units.filter(func(u):return u.team==0 and u.kind!='Pawn' and u.p.x>1100)
  if not invaders.is_empty():focus=invaders[0].p
 elif g.time>240:focus=Vector2(900,650)
 g.cam=g.cam.lerp((focus-Vector2(680,350)).clamp(Vector2(0,-72),g.camera_limit()),0.03)
 g.message.text='1v1 BLUE VISION (4x) | '+g.pace_hint()+' | '+('Blue: grouped assault' if assaults>0 else 'Blue: local defense; assault at 7:30')
func report():return {'camp_events':camp_events,'mining_camps':g.buildings.filter(func(b):return b.kind=='Depot').map(func(b):return {'team':b.team,'hp':b.hp,'progress':b.progress,'started':b.get('started_at',-1),'completed':b.get('completed_at',-1),'gold_delivered':b.get('delivered_gold',0),'wood_delivered':b.get('delivered_wood',0)}),'map_seed':g.map_seed,'map_style':g.map_style,'army_launches':g.supply.planner.launches,'group_withdrawals':g.supply.planner.withdrawals,'research':g.technology.levels,'advanced_buildings':g.buildings.filter(func(b):return b.kind in ['Smith','Workshop']).map(func(b):return [b.team,b.kind,b.progress]),'siege_attacks':g.combat_events.filter(func(e):return e.unit=='Catapult').size(),'supply_scores':g.supply.scores,'supply_events':g.supply.events,'supply_income':g.supply.income,'seconds':g.time,'result':g.outcome,'first_contact':first_contact,'player_expansion':expansions,'player_assaults':assaults,'enemy_attacks':g.opponent.attack_history,'enemy_delivered':g.enemy_gathered,'enemy_trained':g.enemy_trained,'body_contacts':g.blocking.contacts,'ai_retreats':g.opponent.retreat.retreats,'emergency_returns':g.opponent.retreat.emergency_returns}
