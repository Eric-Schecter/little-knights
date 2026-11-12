extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g);g.set_process(false);g.ai_enabled=false
 g.time=60;g.enemy_money=Vector2i(1000,1000)
 var home=g.opponent.owned('Castle')[0]
 for i in range(3):g.units.append(g.entity('Warrior',home.p+Vector2(-150,i*40),1))
 g.opponent.tick(1)
 assert(g.opponent.owned('Barracks')[0].queue.size()==1,'Continue production beyond five soldiers before 150 seconds')
 var w=g.units.filter(func(u):return u.team==1 and u.kind=='Pawn')[0]
 w.p=home.p+Vector2(200,200);w.goal=w.p+Vector2(100,0);w.job=null;w.carry=15;w.returning=true;w['fleeing']=true
 var before=w.p
 g.economy.work(w,0.1)
 assert(w.p.x>before.x and w.carry==15 and w.work_state=='Evacuating','Cargo must not override evacuation movement')
 print('AI RECOVERY PASS: early reinforcement and loaded-worker evacuation');quit()
