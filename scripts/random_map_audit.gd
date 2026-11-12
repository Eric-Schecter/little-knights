extends SceneTree
func _initialize():call_deferred('run')
func fingerprint(g):return str(g.CROSSINGS)+str(g.resources.map(func(r):return [r.kind,r.p,r.amount]))
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g);g.set_process(false);g.ai_enabled=false;g.random_map_enabled=true;g.supply.enabled=true
 var seen={}
 var styles={}
 for seed_value in range(1,21):
  g.requested_map_seed=seed_value;g.reset();g.rebuild_nav()
  var key=fingerprint(g);seen[key]=true;styles[g.map_style]=true
  for resource in g.resources:
   assert(g.resources.any(func(other):return other.kind==resource.kind and other.amount==resource.amount and other.p.distance_to(Vector2(2400-resource.p.x,resource.p.y))<0.01),'Resource mirroring')
  for span in g.CROSSINGS:
   var y=(span.x+span.y)/2
   var path=g.nav.get_point_path(g.nearest_cell(Vector2(1060,y)),g.nearest_cell(Vector2(1340,y)))
   assert(not path.is_empty() and Array(path).any(func(p):return abs(p.x-1200)<30 and p.y>span.x and p.y<span.y),'Each bridge connects both banks')
  for team in range(2):
   var worker=g.units.filter(func(u):return u.team==team and u.kind=='Pawn')[0]
   for resource in g.resources.filter(func(r):return (r.p.x<1200)==(team==0)):
    assert(not g.nav.get_point_path(g.nearest_cell(worker.p),g.nearest_cell(resource.p)).is_empty(),'Every resource reachable')
   assert(g.economy.placement_reason('Smith',Vector2(800 if team==0 else 1600,900),[worker])=='','Reserved building space')
  if seed_value==1:
   g.reset();assert(fingerprint(g)==key,'Identical seed reproduces layout')
 assert(styles.size()==3,'All terrain families generated')
 g.requested_map_seed=-1
 var prior=g.map_style
 for i in range(4):
  g.reset();assert(g.map_style!=prior,'Unseeded restart changes terrain family');prior=g.map_style
 assert(seen.size()==20,'Seeds vary layouts')
 print('RANDOM MAP PASS: 20 seeds, mirrored resources, both bridges, resource reachability, building space, reproducibility and diversity')
 quit()
