extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g)
 await process_frame
 g.ai_enabled=false;g.paused=false;g.units.clear();g.buildings.clear();g.resources.clear();g.formations.clear();g.nav_dirty=true
 var ally=g.entity('Warrior',Vector2(500,600))
 var enemy=g.entity('Warrior',Vector2(600,600),1);enemy.mode='stop';enemy.hp=10000;enemy.max=10000
 g.units=[ally,enemy]
 g.issue_order([ally],Vector2(530,600),null)
 ally.goal=Vector2(530,600)
 g._process(0.016);assert(ally.target==null and ally.mode=='move')
 for i in range(180):g._process(1.0/60)
 assert(ally.mode=='guard' and is_same(ally.target,enemy))
 var hp=enemy.hp
 for i in range(120):g._process(1.0/60)
 assert(enemy.hp<hp)
 g.selected=[ally];g.stop_selected();hp=enemy.hp
 for i in range(120):g._process(1.0/60)
 assert(ally.target==null and enemy.hp==hp and ally.mode=='stop')
 ally.mode='attack';ally.target=null;g.restore_idle_guard(ally);assert(ally.mode=='guard')
 ally.mode='move';ally.goal=ally.p;ally['retreating']=true;g.restore_idle_guard(ally);assert(ally.mode=='move');ally.retreating=false
 var second=g.entity('Warrior',Vector2(450,650));g.units.append(second)
 g.issue_order([ally,second],Vector2(750,650),null)
 var f=g.formations[ally.formation]
 ally.p=ally.goal;ally.slot_velocity=Vector2.ZERO
 g.restore_idle_guard(ally);assert(ally.mode=='move')
 f.anchor.p=f.destination;ally.p=ally.goal;g.restore_idle_guard(ally);assert(ally.mode=='guard')
 var worker=g.entity('Pawn',Vector2(500,500));worker.mode='move';g.restore_idle_guard(worker);assert(worker.mode=='move')
 var barracks=g.entity('Barracks',Vector2(400,400));barracks.rally=Vector2(650,600);barracks.queue=['Warrior'];barracks.train=8
 g.buildings=[barracks];g.units.clear();g.nav_dirty=true
 g.economy.tick_training(barracks,0.016);assert(g.units.size()==1)
 var recruit=g.units[0];assert(recruit.mode=='move')
 recruit.p=recruit.goal;g.restore_idle_guard(recruit);assert(recruit.mode=='guard')
 print('AUTO ATTACK PASS: move remains uninterrupted, arrival acquires and damages enemy, H remains stopped, attack completion, retreat preserved, formation arrival, workers unchanged, trained recruit rally')
 quit()
