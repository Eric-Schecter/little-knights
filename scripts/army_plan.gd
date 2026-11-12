# Objective armies commit together; newly trained troops wait at staging.
extends RefCounted
var g
var teams=[]
var launches=[]
var withdrawals=0
func _init(game):g=game;reset()
func reset():
 teams=[{'assault':false,'members':[],'objective':0,'cooldown':0.0,'threat':[0.0,0.0],'seen':[-999.0,-999.0]}, {'assault':false,'members':[],'objective':0,'cooldown':0.0,'threat':[0.0,0.0],'seen':[-999.0,-999.0]}]
 launches=[];withdrawals=0
func power(u):
 var weight={'Pawn':0.3,'Warrior':1.1,'Spearman':1.0,'Archer':1.1,'Cavalry':1.8,'Catapult':0.65,'Tower':2.8}.get(u.kind,0.0)
 return weight*sqrt(maxf(0,u.hp/u.max))*(1.0+g.technology.bonus(u,'attack')*0.03)
func total(group):
 var value=0.0
 for u in group:value+=power(u)
 return value
func staging(team):return Vector2((g.WORLD.x/2-430) if team==0 else (g.WORLD.x/2+430),g.supply.points[0].p.y)
func enemy_power(team,p):
 return total((g.units+g.buildings).filter(func(u):return u.team!=team and u.hp>0 and g.fog.sees(team,u.p) and u.p.distance_to(p)<340))
func plan(team):
 var state=teams[team]
 var army=g.units.filter(func(u):return u.team==team and u.hp>0 and u.kind!='Pawn' and (team!=1 or not g.opponent.defense.active or not g.contains_entity(g.opponent.defense.defenders,u)))
 state.members=state.members.filter(func(u):return u.hp>0 and g.contains_entity(army,u))
 var critical=false
 for i in range(2):
  var p=g.supply.points[i].p
  if g.fog.sees(team,p):state.threat[i]=enemy_power(team,p);state.seen[i]=g.time
  elif g.time-state.seen[i]>45:state.threat[i]*=0.9
 var rally=staging(team)
 if not state.members.is_empty():
  var center=Vector2.ZERO
  for u in state.members:center+=u.p
  center/=state.members.size()
  var danger=enemy_power(team,center)
  var fragmented=state.members.any(func(u):return u.get('retreating',false))
  if not critical and (danger>total(state.members)*1.4 or fragmented):
   var home=g.buildings.filter(func(b):return b.team==team and b.kind=='Castle' and b.hp>0)
   if not home.is_empty():
    var destination=home[0].p+Vector2(160 if team==0 else -160,80)
    g.issue_order(state.members,destination,null,'move')
    for u in state.members:u['army_recover_until']=g.time+16;u['supply_task']=-1
   state.assault=false;state.members=[];state.cooldown=g.time+16;withdrawals+=1
  elif not state.assault and state.members.size()>=6 and g.supply.points[state.objective].owner==team:
   state.assault=true
   g.issue_order(state.members,assault_destination(team),null,'attack_move')
 var reserves=army.filter(func(u):return not state.members.any(func(v):return is_same(v,u)) and not u.get('retreating',false) and g.time>=u.get('retreat_cooldown',0) and g.time>=u.get('army_recover_until',0))
 var traveling=reserves.filter(func(u):return u.p.distance_to(rally)>110 and u.target==null and (u.goal.distance_to(rally)>80 or u.mode=='attack_move'))
 if not traveling.is_empty():g.issue_order(traveling,rally,null,'move')
 var ready=reserves.filter(func(u):return u.p.distance_to(rally)<=150 and u.target==null)
 if critical:ready=reserves
 if ready.is_empty() or (not critical and (ready.size()<4 or g.time<state.cooldown)):return
 # Judge an attack using the field group AND its ready reinforcement batch.
 var combined=ready.duplicate();combined.append_array(state.members)
 var objective=state.objective if not state.members.is_empty() else 0
 if not state.assault and not critical and state.threat[objective]>total(combined)/1.15:
  if g.supply.points[1-objective].owner!=team and state.threat[1-objective]<=total(combined)/1.15:objective=1-objective
  else:return
 ready=combined
 if not state.assault and not critical and total(ready)<state.threat[objective]*1.15:return
 state.members=ready.duplicate();state.objective=objective
 g.issue_order(ready,assault_destination(team) if state.assault else g.supply.points[objective].p,null,'attack_move')
 for u in ready:u['supply_task']=objective
 launches.append({'team':team,'time':g.time,'count':ready.size(),'objective':objective,'critical':critical})

func assault_destination(team):
 # Opposing starting position is known from the symmetric map; target acquisition still uses fog.
 var home=g.buildings.filter(func(b):return b.team==team and b.kind=='Castle' and b.hp>0)
 return Vector2(g.WORLD.x-home[0].p.x,home[0].p.y) if not home.is_empty() else g.supply.points[0].p
