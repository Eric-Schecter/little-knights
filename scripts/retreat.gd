extends RefCounted
var g
var clock=0.0
var retreats=0
var emergency=false
var emergency_returns=0
func _init(game):g=game
func reset():clock=0;retreats=0;emergency=false;emergency_returns=0
func strength(e):return (1.7 if e.kind=='Cavalry' else (1.2 if e.kind=='Archer' else 1.0))*e.hp/e.max
func tick(dt):
 clock-=dt
 if clock>0:return
 clock=0.5
 var homes=g.buildings.filter(func(b):return b.team==1 and b.kind=='Castle' and b.hp>0)
 if homes.is_empty():return
 var home=homes[0]
 # Core defense overrides survival, including already retreating soldiers.
 var threats=g.units.filter(func(e):return e.team==0 and e.hp>0 and e.kind!='Pawn' and g.fog.sees(1,e.p))
 emergency=threats.any(func(e):return e.p.distance_to(home.p)<230 or (is_same(e.target,home) and e.p.distance_to(home.p)<360) or (home.hp/home.max<0.4 and e.p.distance_to(home.p)<400))
 var army=g.units.filter(func(u):return u.team==1 and u.kind!='Pawn' and u.hp>0)
 if emergency:
  for u in army:
   if u.get('retreating',false):
    u.retreating=false;u['retreat_until']=0;u['retreat_cooldown']=g.time+15;emergency_returns+=1
    g.issue_order([u],home.p+Vector2(-140,80),null,'attack_move')
  return
 for u in army:
  if u.get('retreating',false):
   if g.time>=u.get('retreat_until',0) and u.p.distance_to(home.p)<300:
    u.retreating=false;u.mode='guard';u['retreat_cooldown']=g.time+15
   continue
  if u.p.distance_to(home.p)<330 or g.time<u.get('retreat_cooldown',0):continue
  var enemies=g.units.filter(func(e):return e.team==0 and e.hp>0 and e.kind!='Pawn' and g.fog.sees(1,e.p) and e.p.distance_to(u.p)<300)
  if enemies.is_empty():continue
  var friends=army.filter(func(a):return not a.get('retreating',false) and a.p.distance_to(u.p)<260)
  var ours=0.0;var theirs=0.0;var danger=Vector2.ZERO
  for a in friends:ours+=strength(a)
  for e in enemies:theirs+=strength(e);danger+=e.p
  danger/=enemies.size()
  if theirs<ours*1.7:continue
  var destination=home.p+Vector2(-160,130)
  if g.nav_dirty:g.rebuild_nav()
  var path=g.nav.get_point_path(g.nearest_cell(u.p),g.nearest_cell(destination))
  if path.size()<2:continue
  var exit_point=path[min(5,path.size()-1)]
  if exit_point.distance_to(danger)<u.p.distance_to(danger)+15:continue
  if enemies.any(func(e):return e.p.distance_to(exit_point)<60):continue
  for a in friends:
   a['retreating']=true;a['retreat_until']=g.time+18
  g.issue_order(friends,destination,null,'move')
  retreats+=1
