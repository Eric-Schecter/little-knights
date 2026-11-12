extends RefCounted
var g
func _init(game):g=game
func valid(u,b):
 return b!=null and g.contains_entity(g.buildings,b) and b.team==u.team and b.hp>0 and b.progress>=1 and b.hp<b.max
func clear(u):
 u['repair_target']=null;u['auto_repair']=false;u['repair_clock']=0.0
func assign(u,b):
 clear(u);u['repair_target']=b;u.job=null;u.returning=false;u.target=null;u.mode='repair';u.work_clock=0
func toggle():
 var workers=g.selected.filter(func(u):return u.kind=='Pawn' and g.contains_entity(g.units,u) and u.hp>0)
 if workers.is_empty():return
 var enable=not workers.all(func(u):return u.get('auto_repair',false))
 for u in workers:
  g.issue_order([u],u.p,null)
  u.goal=u.p;u.formation=-1;u['auto_repair']=enable;u['repair_origin']=u.p;u['repair_scan']=0.0
 g.tell('Auto repair enabled: nearby friendly buildings. 1 wood / 10 HP.' if enable else 'Auto repair disabled.')
 g.refresh_commands()
func find_target(u):
 if g.nav_dirty:g.rebuild_nav()
 var choices=g.buildings.filter(func(b):return valid(u,b) and b.p.distance_to(u.repair_origin)<450)
 choices.sort_custom(func(a,b):return u.p.distance_squared_to(a.p)<u.p.distance_squared_to(b.p))
 for b in choices:
  var point=g.target_point(b,u.p)
  var aim=point+(u.p-point).normalized()*18
  if not g.nav.get_point_path(g.nearest_cell(u.p),g.nearest_cell(aim)).is_empty():return b
 return null
func tick(u,dt):
 var target=u.get('repair_target')
 if target!=null and not valid(u,target):
  u['repair_target']=null;u['repair_clock']=0.0;u.goal=u.p;u.path=PackedVector2Array();target=null
 if target==null and u.get('auto_repair',false):
  u['repair_scan']=u.get('repair_scan',0.0)-dt
  if u.repair_scan<=0:
   u.repair_scan=0.5;target=find_target(u);u['repair_target']=target
  if target==null:u.work_state='Auto repair: waiting';u.moving=false;return true
 if target==null:
  if u.mode=='repair':u.mode='move';u.goal=u.p
  return false
 if g.economy.balance(u.team).y<1:
  u.work_state='Repair: need wood';u.moving=false;return true
 var point=g.target_point(target,u.p)
 var aim=point+(u.p-point).normalized()*18
 u.work_state='To repair'
 if g.move_unit(u,aim,dt,5):
  u.work_state='Repairing';u.work_clock=fposmod(u.work_clock+dt,0.55)
  u['repair_clock']=u.get('repair_clock',0.0)+dt
  if u.repair_clock>=0.5:
   u.repair_clock-=0.5
   g.economy.credit(u.team,Vector2i(0,-1));target.hp=minf(target.max,target.hp+10)
   g.sfx.play('build',u.p)
 return true
