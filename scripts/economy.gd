extends RefCounted
var g
var placement_path_key=[]
var placement_path_result=false
func _init(game):g=game
func price(kind):return {'Pawn':Vector2i(50,0),'Warrior':Vector2i(80,0),'Archer':Vector2i(60,30),'Spearman':Vector2i(55,20),'Cavalry':Vector2i(125,40),'Catapult':Vector2i(140,100)}.get(kind,Vector2i.ZERO)
func notify(team,text):
 if team==0:g.tell(text)
func balance(team):return Vector2i(g.gold,g.wood) if team==0 else g.enemy_money
func credit(team,amount):
 if team==0:g.gold+=amount.x;g.wood+=amount.y
 else:g.enemy_money+=amount
func duration(kind):return {'Pawn':5.0,'Spearman':7.0,'Catapult':16.0,'Cavalry':12.0}.get(kind,8.0)
func train(kind,b):
 if g.outcome!='':return false
 var reasons=training_requirements(kind,b)
 if not reasons.is_empty():notify(b.team,'; '.join(reasons));return false
 var p=price(kind)
 credit(b.team,-p);b.queue.append(kind);notify(b.team,g.NAMES[kind]+' queued. Click its queue card to cancel.')
 if b.team==0 and g.icon_hud!=null:g.icon_hud.update_training_buttons()
 return true
func cancel(b,index):
 if g.outcome!='':return false
 if b.hp<=0 or b.team!=0 or index<0 or index>=b.queue.size():return false
 var kind=b.queue[index];var p=price(kind)
 b.queue.remove_at(index);g.gold+=p.x;g.wood+=p.y
 if index==0:b.train=0.0
 g.tell('Cancelled %s: +%d gold, +%d wood (full refund).'%[g.NAMES[kind],p.x,p.y]);return true
func update_unit_rally(b):
 var leader=b.get('rally_unit')
 if leader==null:return
 if leader.hp<=0 or not g.contains_entity(g.units,leader):
  b['rally_unit']=null;b['rally_resource']=null;b['rally_disabled']=true
  b.rally=b.p+Vector2(0,76);b['spawned']=0
 else:b.rally=leader.p
func tick_training(b,dt):
 update_unit_rally(b)
 if b.queue.is_empty() or b.progress<1 or b.hp<=0:return
 if g.population(b.team)>g.capacity(b.team):return
 b.train+=dt
 if b.train<duration(b.queue[0]):return
 if g.nav_dirty:g.rebuild_nav()
 var spawn=b.p+Vector2(0,76)
 spawn=Vector2(g.nearest_cell(spawn))*20+Vector2(10,10)
 if not g.blocking.clear_at(spawn,b.team,18.0 if b.queue[0]=="Cavalry" else 12.0):return
 var u=g.entity(b.queue.pop_front(),spawn,b.team)
 var no_rally=b.get('rally_disabled',false)
 var destination=spawn if no_rally else b.rally
 for slot in range(0 if no_rally else 100):
  var candidate=b.rally+Vector2((slot%5)*42,int(slot/5)*42)
  candidate=Vector2(g.nearest_cell(candidate))*20+Vector2(10,10)
  if g.units.any(func(other):return other.hp>0 and (other.p.distance_to(candidate)<26 or (other.team==b.team and other.goal.distance_to(candidate)<26))):continue
  destination=candidate;break
 u.goal=destination;b['spawned']=int(b.get('spawned',0))+1
 g.match_results.trained(b.team,u.kind)
 u.mode='guard' if no_rally else 'move'
 var leader=b.get('rally_unit')
 if leader!=null and leader.hp>0 and g.contains_entity(g.units,leader):
  u['follow_unit']=leader;u.mode='follow'
  var slot=int(b.get('spawned',1))-1
  u['follow_offset']=Vector2(0,64+28*int(slot/8)).rotated((slot%8)*TAU/8)
  u.goal=leader.p+u.follow_offset
 var resource=b.get('rally_resource')
 if u.kind=='Pawn' and resource!=null:
  if resource.amount<=0 or not g.contains_entity(g.resources,resource):
   resource=nearby_resource(u,resource.kind,resource.p)
  if resource!=null:
   u.job=resource;u.goal=resource.p;u.carry_kind=resource.kind;u.mode='move'
   u['follow_unit']=null;b['rally_resource']=resource;b.rally=resource.p
  else:
   u.goal=u.p
   notify(b.team,'Resource rally depleted: no nearby '+b.rally_resource.kind+'. Worker is idle.')
 g.units.append(u);b.train=0.0;g.trained+=1
 if b.team==0:g.sfx.play('train')
 else:g.enemy_trained+=1
func nearby_resource(u,kind,origin):
 if g.nav_dirty:g.rebuild_nav()
 var best=null;var best_length=INF
 for r in g.resources:
  if r.kind!=kind or r.amount<=0 or r.p.distance_to(origin)>500:continue
  var path=g.nav.get_point_path(g.nearest_cell(u.p),g.nearest_cell(r.p))
  if path.is_empty():continue
  var length=0.0
  for i in range(1,path.size()):length+=path[i].distance_to(path[i-1])
  if length<best_length:best=r;best_length=length
 return best
func home_for(u):
 var best=null;var dist=INF
 for b in g.buildings:
  if b.team==u.team and b.kind in ['Castle','Depot'] and b.hp>0 and b.progress>=1 and b.p.distance_to(u.p)<dist:best=b;dist=b.p.distance_to(u.p)
 return best
func work(u,dt):
 if u.get('fleeing',false):
  u.work_state='Evacuating';g.move_unit(u,u.goal,dt);return
 if g.repairs.tick(u,dt):return
 if u.job!=null and u.job.has('hp') and u.job.hp<=0:u.job=null
 if u.job!=null and u.job.has('amount') and u.job.amount<=0:
  var old=u.job
  if u.carry>0:u.returning=true
  u.job=nearby_resource(u,old.kind,old.p)
  if u.job==null and u.carry==0:u.goal=u.p;notify(u.team,'No nearby '+old.kind+'. Worker is idle.')
 if u.carry>=15 and u.job!=null and u.job.has('amount'):u.returning=true
 if u.returning and u.carry>0:
  u.work_state='Returning '+u.carry_kind
  var home=home_for(u)
  if home==null:u.work_state='No drop-off point';return
  var point=g.target_point(home,u.p)
  var aim=point+(u.p-point).normalized()*18
  if g.move_unit(u,aim,dt,5):
   if home.kind=='Depot':home['delivered_'+u.carry_kind]=home.get('delivered_'+u.carry_kind,0)+u.carry
   g.match_results.delivered(u.team,u.carry_kind,u.carry)
   credit(u.team,Vector2i(u.carry,0) if u.carry_kind=='gold' else Vector2i(0,u.carry))
   if u.team==1:g.enemy_gathered+=u.carry
   g.sfx.play('deliver',u.p)
   g.gathered+=u.carry;g.floating(u.p,'+'+str(u.carry),Color('#f7d675'));u.carry=0;u.returning=false;u.work_clock=0.0
   if u.job==null:u.goal=u.p
  return
 if u.carry==0:u.returning=false
 if u.job!=null and u.job.has('amount'):
  var r=u.job
  if u.carry>0 and u.carry_kind!=r.kind:u.returning=true;return
  u.carry_kind=r.kind
  u.work_state='To '+r.kind
  if abs(r.p.x-u.p.x)>1:u.face=1 if r.p.x>u.p.x else -1
  if g.move_unit(u,r.p,dt,36):
   u.work_state='Mining' if r.kind=='gold' else 'Chopping'
   u.work_clock+=dt
   if u.work_clock>=0.55:
    var amount=min(3,min(r.amount,15-u.carry))
    u.work_clock=0.0;u.carry+=amount;r.amount-=amount
    if amount>0:g.sfx.play('mine' if r.kind=='gold' else 'wood',u.p)
  return
 if u.job!=null and u.job.has('progress'):
  var b=u.job
  if b.progress>=1:u.job=null;u.goal=u.p;u.work_state='Idle';return
  var point=g.target_point(b,u.p)
  var aim=point+(u.p-point).normalized()*18
  u.work_state='To construction'
  if g.move_unit(u,aim,dt,5):
   if b.progress<=0:
    var half=g.footprint(b)
    if g.units.any(func(other):return other.hp>0 and not is_same(other,u) and abs(other.p.x-b.p.x)<half.x and abs(other.p.y-b.p.y)<half.y):
     u.work_state='Waiting for clear foundation';return
   u.work_state='Building'
   var previous_clock=u.work_clock
   u.work_clock=fposmod(u.work_clock+dt,0.55)
   if u.work_clock<previous_clock:g.sfx.play('build',u.p)
   if abs(b.p.x-u.p.x)>1:u.face=1 if b.p.x>u.p.x else -1
   var added=min(1.0-b.progress,dt/12)
   var starting=b.progress<=0
   b.progress+=added;b.hp=min(b.max,b.hp+b.max*added)
   if starting:g.invalidate_building_nav(b)
   if b.progress>=1:
    b['completed_at']=g.time
    notify(u.team,g.NAMES[b.kind]+' complete.')
    if b.team==0:g.sfx.play('complete')
    else:g.sfx.play('complete',b.p)
  return
 u.work_state='Moving' if u.p.distance_to(u.goal)>5 else 'Idle'
 g.move_unit(u,u.goal,dt)
func placement_reason(kind,p,workers,check_money=true):
 if kind not in ['House1','Barracks','Tower','Smith','Workshop','Depot']:return 'Choose a building.'
 if workers.is_empty():return 'Select a worker first.'
 if check_money and balance(workers[0].team).y<g.cost(kind):return 'Not enough wood: need %d.'%g.cost(kind)
 var half=g.building_half_size(kind);var area=Rect2(p-half,half*2)
 for corner in [p-half,p+half,p+Vector2(-half.x,half.y),p+Vector2(half.x,-half.y)]:
  if not g.land(corner):return 'The whole foundation must be on land.'
 if g.crossing_reserved(area):return 'Keep the bridge passage clear.'
 for b in g.buildings:
  if b.hp>0 and area.grow(12).intersects(Rect2(b.p-g.footprint(b),g.footprint(b)*2)):return 'Blocked by another building.'
 for r in g.resources:
  if r.amount>0 and area.grow(30).has_point(r.p):return 'Blocked by a tree or gold deposit.'
 for u in g.units:
  if u.hp>0 and area.grow(14).has_point(u.p):return 'Move units away from the foundation.'
 if g.nav_dirty:g.rebuild_nav()
 var destination=g.nearest_cell(p)
 var origins=workers.map(func(worker):return g.nearest_cell(worker.p))
 var key=[g.nav_revision,destination,origins]
 var reachable=placement_path_result
 if key!=placement_path_key:
  reachable=false
  for origin in origins:
   if not g.nav.get_point_path(origin,destination).is_empty():reachable=true;break
  placement_path_key=key;placement_path_result=reachable
 if not reachable:return 'Workers cannot reach this site.'
 return ''
func place(kind,p,workers):
 if g.outcome!='':return null
 var reason=placement_reason(kind,p,workers)
 if reason!='':
  if not workers.is_empty():notify(workers[0].team,reason)
  return null
 var b=g.entity(kind,p,workers[0].team);b.progress=0.0;b.hp=1.0
 g.buildings.append(b);g.invalidate_building_nav(b);credit(workers[0].team,Vector2i(0,-g.cost(kind)))
 for u in workers:
  g.repairs.clear(u)
  u.job=b;u.target=null;u.pending=null;u.windup=0;u.formation=-1;u.path=PackedVector2Array();u.returning=u.carry>0
 if workers[0].team==0:g.build_mode='';g.tell('Construction ordered. Workers must reach the site.')
 return b

func plan_expansion(team,workers):
 if not g.random_map_enabled or workers.size()<6:return
 var camps=g.buildings.filter(func(b):return b.team==team and b.kind=='Depot' and b.hp>0)
 if camps.is_empty():
  var home_gold=g.resources.filter(func(r):return r.kind=='gold' and r.get('zone','')=='HOME' and (r.p.x<g.WORLD.x/2)==(team==0))
  if g.time<100 and not home_gold.is_empty() and home_gold[0].amount>450:return
  if balance(team).y<g.cost('Depot') or g.buildings.any(func(b):return b.team==team and b.hp>0 and b.progress<1):return
  var sites=g.random_map.expansions.filter(func(site):return site.team==team and site.zone=='NATURAL')
  var homes=g.buildings.filter(func(b):return b.team==team and b.kind=='Castle' and b.hp>0)
  if homes.is_empty():return
  sites.sort_custom(func(a,b):return a.camp.distance_to(homes[0].p)<b.camp.distance_to(homes[0].p))
  for site in sites:
   if g.units.any(func(u):return u.team!=team and u.hp>0 and g.fog.sees(team,u.p) and u.p.distance_to(site.camp)<300):continue
   if placement_reason('Depot',site.camp,[workers[-1]])=='':
    var camp=place('Depot',site.camp,[workers[-1]])
    camp['expansion_mine']=site.p;camp['started_at']=g.time
    return
 else:
  var camp=camps[0]
  if camp.progress<1:return
  var mine_pos=camp.get('expansion_mine',camp.p)
  var miners=workers.filter(func(w):return w.job!=null and w.job.has('amount') and w.job.kind=='gold' and w.job.p.distance_to(mine_pos)<100)
  if miners.size()>=3:return
  var sources=g.resources.filter(func(r):return r.kind=='gold' and r.amount>0 and r.p.distance_to(mine_pos)<100)
  if sources.is_empty():return
  var available=workers.filter(func(w):return not w.get('fleeing',false) and not miners.any(func(m):return is_same(m,w)) and (w.job==null or w.job.has('amount')))
  available.sort_custom(func(a,b):return a.p.distance_to(camp.p)<b.p.distance_to(camp.p))
  for w in available.slice(0,mini(3-miners.size(),maxi(0,workers.size()-3-miners.size()))):g.issue_order([w],sources[0].p,sources[0])

func training_requirements(kind,b):
 var reasons:PackedStringArray=[]
 if b.hp<=0:reasons.append('Building destroyed')
 elif b.progress<1:reasons.append('Complete the building')
 if kind not in {'Castle':['Pawn'],'Barracks':['Warrior','Archer','Spearman','Cavalry'],'Workshop':['Catapult']}.get(b.kind,[]):reasons.append('Requires the correct production building')
 if kind=='Cavalry' and not g.buildings.any(func(f):return f.team==b.team and f.kind=='Smith' and f.hp>0 and f.progress>=1):reasons.append('Requires a completed Blacksmith')
 var missing_pop=g.population(b.team)+g.population_cost(kind)-g.capacity(b.team)
 if missing_pop>0:reasons.append('Need %d more population capacity (build a House)'%missing_pop)
 var p=price(kind);var money=balance(b.team)
 if money.x<p.x:reasons.append('Need %d more gold'%(p.x-money.x))
 if money.y<p.y:reasons.append('Need %d more wood'%(p.y-money.y))
 if b.queue.size()>=5:reasons.append('Training queue is full (5/5)')
 return reasons
