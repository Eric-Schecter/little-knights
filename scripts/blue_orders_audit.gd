extends SceneTree
var failures=[]
func _initialize():call_deferred('run')
func check(ok,label):
 if not ok:failures.append(label)
 print(('PASS ' if ok else 'FAIL ')+label)
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g);g.set_process(false);g.ai_enabled=false
 g.units.clear();g.resources.clear();g.nav_dirty=true
 var driver=load('res://scripts/match_driver.gd').new(g)
 var army=[]
 for i in range(12):
  var u=g.entity('Warrior',Vector2(780+(i%3)*42,620+int(i/3)*42));g.units.append(u);army.append(u)
 var enemy=g.entity('Warrior',Vector2(980,680),1);g.units.append(enemy);g.fog.update()
 driver.tick(1)
 check(army.all(func(u):return u.mode=='guard' and u.formation==army[0].formation),'Home response is one guard group')
 var u=army[0];u.target=enemy;enemy.p=u.goal+Vector2(300,0);g.fog.update();g._process(1.0/30)
 check(u.target==null,'Guard releases enemy beyond defense perimeter')
 g.time=450;driver.tick(1.1)
 check(army.all(func(a):return a.get('review_assault',false) and a.mode=='attack_move'),'Attack commits all twelve soldiers without hidden reserve')
 var fid=army[0].formation
 check(army.all(func(a):return a.formation==fid),'Attacking army keeps a shared formation order')
 enemy.p=Vector2(850,680);g.fog.update();driver.tick(1.1)
 check(army.all(func(a):return a.mode=='attack_move' and a.formation==fid),'New home threat does not overwrite committed assault')
 var f=g.formations[fid]
 enemy.p=Vector2(1100,680);enemy.hp=100;army[0].target=enemy;g.fog.update();g.update_formations(1.0/30)
 check(army.all(func(a):return a.target!=null),'Idle attack squad members support nearby contact')
 for i in range(army.size()):army[i].p=Vector2(1450+(i%3)*46,600+int(i/3)*46);army[i].target=null
 enemy.hp=0;g.fog.update();g.update_formations(1.0/30)
 check(f.anchor.p.x>1400 and army.all(func(a):return a.goal.x>1350),'Combat end resumes from current position rather than old riverbank slots')
 print('BLUE ORDERS AUDIT failures=',failures);quit(0 if failures.is_empty() else 1)
