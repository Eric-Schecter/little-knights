extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g)
 await process_frame
 g.paused=true;g.ai_enabled=false
 var worker=g.units[0]
 var home=g.buildings.filter(func(b):return b.kind=='Castle' and b.team==0)[0]
 home.hp=home.max-20
 worker.p=home.p+Vector2(0,100)
 g.issue_order([worker],home.p,home)
 assert(is_same(worker.repair_target,home))
 var before=g.wood
 for i in range(600):g.economy.work(worker,1.0/60)
 assert(home.hp==home.max and g.wood==before-2)
 assert(worker.repair_target==null)
 home.hp-=20;g.wood=0;g.issue_order([worker],home.p,home)
 for i in range(120):g.economy.work(worker,1.0/60)
 assert(home.hp==home.max-20 and g.wood==0)
 g.wood=10;g.selected=[worker];assert(worker.auto_repair)
 for i in range(600):g.economy.work(worker,1.0/60)
 assert(home.hp==home.max and worker.auto_repair)
 home.hp-=10
 for i in range(300):g.economy.work(worker,1.0/60)
 assert(home.hp==home.max)
 g.stop_selected();assert(worker.auto_repair and worker.repair_target==null)
 home.hp-=10
 for i in range(120):g.economy.work(worker,1.0/60)
 assert(home.hp==home.max-10)
 # A new move preserves the default and resumes maintenance after arrival.
 g.issue_order([worker],worker.p+Vector2(60,0),null)
 for i in range(600):g.economy.work(worker,1.0/60)
 assert(home.hp==home.max)
 g.repairs.toggle();assert(not worker.auto_repair)
 home.hp-=10
 for i in range(120):g.economy.work(worker,1.0/60)
 assert(home.hp==home.max-10)
 g.repairs.toggle();assert(worker.auto_repair)
 var resource=g.resources.filter(func(r):return r.amount>0)[0]
 g.issue_order([worker],resource.p,resource)
 g.repairs.tick(worker,1.0);assert(worker.repair_target==null and is_same(worker.job,resource))
 var newborn=g.entity('Pawn',worker.p);assert(newborn.auto_repair)
 newborn.goal=newborn.p;g.units.append(newborn)
 for i in range(600):g.economy.work(newborn,1.0/60)
 assert(home.hp==home.max)
 var enemy=g.buildings.filter(func(b):return b.team==1)[0];enemy.hp-=10
 assert(not g.repairs.valid(worker,enemy))
 home.progress=0.5;home.hp-=10;assert(not g.repairs.valid(worker,home))
 print('REPAIR PASS: right click, approach, healing/cost, full stop, no wood, auto scan and rescan, H cancellation, enemy and construction excluded')
 quit()
