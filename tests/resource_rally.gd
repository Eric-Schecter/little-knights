extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g)
 await process_frame
 g.paused=true;g.ai_enabled=false
 var tree={'kind':'wood','p':Vector2(600,600),'amount':100}
 assert(g.art.tree_hit(tree,tree.p-Vector2(0,70)))
 assert(not g.art.tree_hit(tree,tree.p+Vector2(80,-100)))
 var home=g.buildings.filter(func(b):return b.team==0 and b.kind=='Castle')[0]
 var leader=g.units[0]
 g.issue_order([home],leader.p,leader)
 assert(is_same(home.rally_unit,leader))
 home.queue=['Pawn'];home.train=5
 var count=g.units.size()
 g.economy.tick_training(home,0.01)
 assert(g.units.size()==count+1)
 var follower=g.units[-1]
 assert(follower.mode=='follow' and is_same(follower.follow_unit,leader))
 follower.p=leader.p+follower.follow_offset
 g.follow_step(follower,0.016);assert(follower.follow_wait and not follower.moving)
 leader.p+=Vector2(15,0);g.follow_step(follower,0.016);assert(not follower.moving)
 leader.p+=Vector2(70,0);g.follow_step(follower,0.016);assert(not follower.follow_wait)
 g.issue_order([follower],follower.p,null)
 assert(follower.follow_unit==null)
 g.issue_order([home],Vector2(800,600),null);assert(home.rally_unit==null)
 follower.follow_unit=leader;follower.mode='follow';leader.hp=0
 g.follow_step(follower,0.016);assert(follower.follow_unit==null and follower.mode=='guard')
 print('RESOURCE RALLY PASS: tree silhouette, transparent miss, unit rally, actual production, follow hysteresis, new order cancellation, ground override, leader death')
 quit()
