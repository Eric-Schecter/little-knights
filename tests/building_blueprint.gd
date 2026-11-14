extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g)
 await process_frame
 g.set_process(false);g.ai_enabled=false;g.paused=false;g.buildings.clear();g.units.clear();g.resources.clear();g.map_style='plains';g.nav_dirty=true
 var plan=g.entity('Barracks',Vector2(700,550),1);plan.progress=0;plan.hp=1;g.buildings=[plan]
 var sword=g.entity('Warrior',Vector2(620,550));g.units=[sword]
 for i in range(30):g._process(1.0/60)
 assert(sword.target==null and not g.can_attack(sword,plan))
 g.damage(plan,500);assert(plan.hp==1)
 assert(g.pick(plan.p-Vector2(0,40),false)==null)
 assert(g.walkable(plan.p))
 var worker=g.entity('Pawn',Vector2(700,610),1);g.units.append(worker);g.issue_order([worker],plan.p,plan)
 for i in range(120):g.economy.work(worker,1.0/60)
 assert(plan.progress>0 and g.attackable(plan) and not g.walkable(plan.p))
 var hp=plan.hp;g.damage(plan,1);assert(plan.hp==hp-1)
 print('BLUEPRINT PASS: no auto target/click/damage before work, no phantom blocker; work starts normal collision and vulnerability')
 quit()
