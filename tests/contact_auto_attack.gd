extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g)
 await process_frame
 g.set_process(false);g.ai_enabled=false;g.paused=false;g.units.clear();g.buildings.clear();g.resources.clear();g.formations.clear();g.nav_dirty=true
 var ally=g.entity('Warrior',Vector2(500,600))
 var enemy=g.entity('Warrior',Vector2(540,600),1);enemy.mode='stop';enemy.hp=10000;enemy.max=10000
 g.units=[ally,enemy];g.issue_order([ally],Vector2(600,600),null)
 ally.goal=Vector2(600,600)
 for i in range(240):g._process(1.0/60)
 assert(ally.mode=='guard' and is_same(ally.target,enemy),'Enemy collision must not lock a soldier in move mode')
 assert(enemy.hp<10000,'Blocked soldier should retaliate')
 ally.p=Vector2(500,600);enemy.p=Vector2(540,600);enemy.hp=10000
 g.issue_order([ally],Vector2(600,600),null);ally.goal=Vector2(600,600);ally['retreating']=true
 for i in range(180):g._process(1.0/60)
 assert(ally.mode=='move' and ally.target==null and enemy.hp==10000)
 ally.retreating=false;g.selected=[ally];g.stop_selected()
 for i in range(180):g._process(1.0/60)
 assert(ally.mode=='stop' and ally.target==null)
 g.units.clear();g.formations.clear()
 var squad=[]
 for i in range(4):
  var soldier=g.entity('Warrior',Vector2(450,540+i*32));squad.append(soldier)
 g.units=squad.duplicate()
 var wall=[]
 for i in range(8):
  var defender=g.entity('Warrior',Vector2(580,490+i*24),1);defender.mode='stop';defender.hp=10000;defender.max=10000;g.units.append(defender);wall.append(defender)
 g.issue_order(squad,Vector2(700,580),null)
 for i in range(600):g._process(1.0/60)
 assert(wall.any(func(u):return u.hp<10000),'Formation must engage blocking enemies too')
 print('CONTACT AUTO ATTACK PASS: real collision, acquisition, damage, retreat and H preserved')
 quit()
