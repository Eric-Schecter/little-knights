extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g)
 await process_frame
 g.paused=true;g.ai_enabled=false
 var home=g.buildings.filter(func(b):return b.team==0 and b.kind=='Castle')[0]
 # Isolate the gathering scenario from randomized starter building footprints.
 g.buildings=[home]
 for kind in ['gold','wood']:
  g.units.clear();g.resources.clear();g.nav_dirty=true
  var resource={'kind':kind,'p':home.p+Vector2(180,120),'amount':100}
  var backup={'kind':kind,'p':home.p+Vector2(250,120),'amount':100}
  g.resources.append(resource);g.resources.append(backup)
  g.issue_order([home],resource.p,resource)
  assert(is_same(home.rally_resource,resource) and home.rally_unit==null)
  assert(g.economy.train('Pawn',home));home.train=5
  g.economy.tick_training(home,0.01)
  assert(g.units.size()==1)
  var worker=g.units[0]
  assert(is_same(worker.job,resource))
  var money=g.economy.balance(0)
  for i in range(1800):g.economy.work(worker,1.0/60)
  assert(g.economy.balance(0).x>money.x if kind=='gold' else g.economy.balance(0).y>money.y)
  resource.amount=0;g.economy.work(worker,0.016)
  assert(is_same(worker.job,backup))
  g.units.clear();home.queue=['Pawn'];home.train=5;g.economy.tick_training(home,0.01)
  assert(is_same(g.units[0].job,backup))
  backup.amount=0;g.units.clear();home.queue=['Pawn'];home.train=5;g.economy.tick_training(home,0.01)
  assert(g.units[0].job==null and g.units[0].goal==g.units[0].p)
  g.issue_order([home],g.units[0].p,g.units[0]);assert(home.rally_resource==null)
  g.issue_order([home],home.p+Vector2(200,0),null);assert(home.rally_resource==null and home.rally_unit==null)
 print('WORKER RESOURCE RALLY PASS: gold/wood production, gather and delivery, depletion retarget, depleted before spawn, idle fallback, unit and ground overrides')
 quit()
