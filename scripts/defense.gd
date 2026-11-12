extends RefCounted
var g
var clock=0.0
var home_alert=false
var active=false
var last_seen=-100.0
var defenders=[]
var alerts=0
var recalls=0
var evacuations=0
var threats=[]
func _init(game):g=game
func reset():home_alert=false;clock=0;active=false;last_seen=-100;defenders.clear();threats.clear();alerts=0;recalls=0;evacuations=0
func tick(dt):
 clock-=dt
 if clock>0:return
 clock=0.25
 var bases=g.buildings.filter(func(b):return b.team==1 and b.hp>0)
 var homes=bases.filter(func(b):return b.kind=='Castle')
 if homes.is_empty():return
 var home=homes[0]
 var workers=g.units.filter(func(u):return u.team==1 and u.hp>0 and u.kind=='Pawn')
 var army=g.units.filter(func(u):return u.team==1 and u.hp>0 and u.kind!='Pawn' and not u.get('retreating',false))
 threats=(g.units+g.buildings).filter(func(e):return e.team==0 and e.hp>0 and g.fog.sees(1,e.p) and ((g.opponent.retreat.emergency and home.p.distance_to(e.p)<400) or bases.any(func(b):return b.p.distance_to(e.p)<360) or workers.any(func(w):return w.p.distance_to(e.p)<300)))
 # Buildings only count as threats if they can fire; workers need to be close.
 threats=threats.filter(func(e):return (not g.contains_entity(g.buildings,e) or e.kind=='Tower') and (e.kind!='Pawn' or bases.any(func(b):return b.p.distance_to(e.p)<180)))
 if not threats.is_empty():
  if not active:alerts+=1
  active=true;last_seen=g.time
  var urgent=g.opponent.retreat.emergency or threats.any(func(e):return e.p.distance_to(home.p)<330)
  home_alert=urgent
  var needed=army.size() if urgent else min(army.size(),max(2,int(ceil(threats.size()*1.5))+1))
  var focus=Vector2.ZERO
  for e in threats:focus+=e.p
  focus/=threats.size()
  army.sort_custom(func(a,b):return a.p.distance_to(focus)<b.p.distance_to(focus))
  # Release yesterday's defenders as the local threat shrinks.
  defenders=defenders.filter(func(u):return army.slice(0,needed).has(u))
  var assigned={}
  for i in range(needed):
   var u=army[i]
   if not g.contains_entity(defenders,u):
    defenders.append(u)
    if u.p.distance_to(home.p)>650 or u.target!=null or (u.mode=='attack_move' and u.goal.x<1500):recalls+=1
   if u.target!=null and g.contains_entity(threats,u.target):continue
   var target=null;var score=INF;var index=-1
   for j in range(threats.size()):
    var candidate=threats[j]
    var value=u.p.distance_to(candidate.p)+assigned.get(j,0)*45+(100 if candidate.kind=='Pawn' else 0)
    if value<score:score=value;target=candidate;index=j
   assigned[index]=assigned.get(index,0)+1
   g.issue_order([u],target.p,target)
  for w in workers:
   var danger=threats.filter(func(e):return e.kind!='Pawn' and e.p.distance_to(w.p)<(300 if e.kind=='Tower' else 210))
   if not danger.is_empty():
    w['safe_after']=g.time+5
    if not w.get('fleeing',false):
     w['saved_job']=w.job;w['fleeing']=true;evacuations+=1
    if g.time>=w.get('evade_replan',0):
     w['evade_replan']=g.time+2
     danger.sort_custom(func(a,b):return a.p.distance_to(w.p)<b.p.distance_to(w.p))
     var away=(home.p-danger[0].p).normalized()
     if away.length()<0.1:away=Vector2.RIGHT
     var destination=home.p+away*180
     if g.nav_dirty:g.rebuild_nav()
     destination=Vector2(g.nearest_cell(destination))*20+Vector2(10,10)
     g.issue_order([w],destination,null,'move')
 else:
  if active and g.time-last_seen>=5:
   active=false;home_alert=false
   var returning=defenders.filter(func(u):return u.hp>0 and not u.get("retreating",false))
   if not returning.is_empty():g.issue_order(returning,home.p+Vector2(-180,100),null,'attack_move')
   defenders.clear()
 for w in workers:
  if w.get('fleeing',false) and g.time>=w.get('safe_after',0):
   w.fleeing=false
   var job=w.get('saved_job',null);w['saved_job']=null
   if job!=null and ((job.has('amount') and job.amount>0) or (job.has('hp') and job.hp>0 and job.progress<1)):
    g.issue_order([w],job.p,job);w.returning=w.carry>0
   elif w.carry>0:w.returning=true
 for u in army:
  if u.mode=='move' and u.target==null and u.p.distance_to(u.goal)<12:u.mode='guard'
