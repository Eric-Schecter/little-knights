extends SceneTree
var g
var failures=[]
var count=0
func _initialize():call_deferred('run')
func check(ok,text):
 count+=1
 if not ok:failures.append(text);push_error(text)
func step(seconds):
 for i in range(int(seconds*30)):g._process(1.0/30)
func run():
 g=load('res://main.tscn').instantiate();root.add_child(g);g.set_process(false);g.ai_enabled=false
 var left={'target':null};var right={'target':null};left.target=right;right.target=left
 check(g.contains_entity([left],left) and not g.contains_entity([left],right),'Cyclic combat targets compare by identity without recursive equality')
 var d=load('res://scripts/roles_demo.gd').new(g)
 d.scene(0)
 var a=d.blue[0];var s=d.red[0]
 check(g.strike_damage(a,s,24)==18,'Sword shield reduces distant arrow damage by six')
 a.p=s.p+Vector2(40,0)
 check(g.strike_damage(a,s,24)==6,'Point blank penalty and shield both apply')
 var worker=g.entity('Pawn',s.p)
 check(g.strike_damage(a,worker,24)==12,'Unarmored target takes half arrow damage at close range')
 var tower=g.entity('Tower',Vector2(900,400),1);g.buildings.append(tower)
 check(g.strike_damage(a,tower,18)==6 and g.strike_damage(s,tower,23)==32,'Swords are better than arrows against structures')
 check(g.strike_damage(tower,s,24)==18,'Shield also protects against tower arrows')
 d.scene(0);step(20)
 var exposed=d.blue.filter(func(u):return u.hp>0).size()
 print('EXPOSED archers surviving=',exposed,' enemy hp=',d.red.map(func(u):return max(0,u.hp)))
 d.scene(1);step(20)
 var protected=d.blue.filter(func(u):return u.hp>0).size()
 print('MIXED surviving=',protected,' enemy hp=',d.red.map(func(u):return max(0,u.hp)))
 check(protected>exposed,'Front line improves survival against the same melee force')
 check(d.blue.any(func(u):return u.kind=='Archer' and u.hp>0),'Protected archer survives the engagement')
 d.scene(2);step(20)
 print('TOWERS vs swords=',d.red[0].hp,' vs archers=',d.red[1].hp)
 check(d.red[0].hp<=0 and d.red[1].hp>0,'Melee group takes tower; unsupported archers do not')
 d.scene(1);g.issue_order(d.blue,Vector2(900,460),null,'move')
 var f=g.formations[-1]
 check(f.members[0].kind=='Warrior' and f.members[1].kind=='Warrior','Mixed formation places swords in the front row')
 step(4)
 check(d.blue.all(func(u):return u.target==null),'Normal move remains a movement command, not forced combat')
 print('ROLES AUDIT: ',count,' checks; failures=',failures)
 quit(0 if failures.is_empty() else 1)
