extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g)
 await process_frame
 g.paused=true;g.ai_enabled=false
 var openings={}
 for seed_value in [101,202,303,404,505,606,707,808,909,1010,1111,1212]:
  g.requested_map_seed=seed_value;g.reset();g.paused=true
  var home=g.buildings.filter(func(b):return b.team==0 and b.kind=='Castle')[0]
  var mine=g.resources.filter(func(r):return r.kind=='gold' and r.get('zone','')=='HOME' and r.p.x<g.WORLD.x/2)[0]
  openings[str(home.p)+str(mine.p)]=true
  g.rebuild_nav()
  for r in g.resources:
   assert(g.resources.any(func(other):return other.kind==r.kind and other.p.is_equal_approx(g.random_map.mirror(r.p)) and other.amount==r.amount))
  for r in g.resources.filter(func(r):return r.kind=='gold' and r.p.x<g.WORLD.x/2):
   assert(not g.nav.get_point_path(g.nearest_cell(home.p+Vector2(0,85)),g.nearest_cell(r.p)).is_empty())
  var snapshot=g.resources.duplicate(true)
  g.reset();g.paused=true;assert(g.resources==snapshot)
 assert(openings.size()==12)
 print('MAP VARIETY PASS: 12 unique openings, mirrored resources, all left mines reachable, fixed seed reproducible')
 quit()
