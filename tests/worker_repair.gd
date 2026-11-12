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
 g.wood=10;g.selected=[worker];g.repairs.toggle()
 for i in range(600):g.economy.work(worker,1.0/60)
 assert(home.hp==home.max and worker.auto_repair)
 home.hp-=10
 for i in range(300):g.economy.work(worker,1.0/60)
 assert(home.hp==home.max)
 g.stop_selected();assert(not worker.auto_repair and worker.repair_target==null)
 var enemy=g.buildings.filter(func(b):return b.team==1)[0];enemy.hp-=10
 assert(not g.repairs.valid(worker,enemy))
 home.progress=0.5;home.hp-=10;assert(not g.repairs.valid(worker,home))
 print('REPAIR PASS: right click, approach, healing/cost, full stop, no wood, auto scan and rescan, H cancellation, enemy and construction excluded')
 quit()
