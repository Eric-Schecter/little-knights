extends SceneTree
var g
func _initialize():call_deferred('run')
func step(seconds):
 for i in range(int(seconds*30)):g._process(1.0/30)
func run():
 g=load('res://main.tscn').instantiate();root.add_child(g);g.set_process(false);g.ai_enabled=false
 assert(g.WORLD==Vector2(3200,2200));assert(g.fog.COLS==160 and g.fog.ROWS==110)
 for number in range(1,11):
  g.requested_map_seed=number;g.reset();g.ai_enabled=false;g.rebuild_nav()
  assert(g.resources.filter(func(r):return r.kind=='gold').size()==12)
  for site in g.random_map.expansions:
   var w=g.units.filter(func(u):return u.team==site.team and u.kind=='Pawn')[0]
   var reason=g.economy.placement_reason('Depot',site.camp,[w])
   assert(reason=='','Expansion pad seed '+str(number)+' '+str(site.camp)+': '+reason)
   assert(not g.nav.get_point_path(g.nearest_cell(w.p),g.nearest_cell(site.camp)).is_empty())
  for r in g.resources:
   assert(g.resources.any(func(other):return other.kind==r.kind and other.amount==r.amount and other.p.distance_to(Vector2(g.WORLD.x-r.p.x,r.p.y))<0.01))
  for span in g.CROSSINGS:
   var y=(span.x+span.y)/2
   var path=g.nav.get_point_path(g.nearest_cell(Vector2(g.WORLD.x/2-160,y)),g.nearest_cell(Vector2(g.WORLD.x/2+160,y)))
   assert(not path.is_empty())
 print('LARGE MAP LAYOUT PASS: 10 seeds / 100 expansion pads, paths, resource symmetry, bridges and fog dimensions')
 g.requested_map_seed=20;g.reset();g.ai_enabled=false;g.supply.enabled=false
 var w=g.units[0];g.units=[w];g.gold=1000;g.wood=1000
 var site=g.random_map.expansions.filter(func(s):return s.team==0 and s.zone=='NATURAL')[0]
 var ore=g.resources.filter(func(r):return r.kind=='gold' and r.p==site.p)[0]
 var camp=g.economy.place('Depot',site.camp,[w]);assert(camp!=null and g.wood==900)
 w.p=site.camp+Vector2(85,0);g.nav_dirty=true
 step(15);assert(camp.progress>=1)
 assert(g.economy.home_for(w)==camp)
 g.issue_order([w],ore.p,ore);var before=g.gold;step(20)
 assert(g.gold>before,'Mining camp receives actual delivered gold')
 camp.hp=0
 assert(g.economy.home_for(w).kind=='Castle','Destroyed camp falls back to town center')
 print('MINING CAMP PASS: construction, payment, local delivery and destruction fallback')
 g.reset();g.ai_enabled=false;g.supply.enabled=false;g.time=110;g.enemy_money=Vector2i(1000,1000)
 for i in range(2):g.units.append(g.entity('Pawn',Vector2(g.WORLD.x-500+i*40,g.WORLD.y*0.45+100),1))
 var red_workers=g.units.filter(func(u):return u.team==1 and u.kind=='Pawn')
 g.economy.plan_expansion(1,red_workers)
 var depots=g.buildings.filter(func(b):return b.team==1 and b.kind=='Depot')
 assert(depots.size()==1 and g.enemy_money.y==900)
 var depot=depots[0]
 var builder=red_workers.filter(func(u):return u.job!=null and is_same(u.job,depot))[0]
 builder.p=depot.p+Vector2(85,0);step(15);assert(depot.progress>=1)
 g.economy.plan_expansion(1,red_workers)
 assert(red_workers.filter(func(u):return u.job!=null and u.job.has('amount') and u.job.kind=='gold' and u.job.p==depot.expansion_mine).size()==3)
 print('AI EXPANSION PASS: paid camp construction and three local miners with three home workers retained')
 quit()
