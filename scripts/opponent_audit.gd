extends SceneTree
var g
var failures=[]
func _initialize():call_deferred('run')
func simulate(seconds):
 for i in range(int(seconds*30)):g._process(1.0/30.0)
func check(ok,text):
 if not ok:failures.append(text);push_error(text)
 else:print('PASS: '+text)
func run():
 g=load('res://main.tscn').instantiate();root.add_child(g);g.set_process(false)
 check(g.units.filter(func(u):return u.team==1 and u.kind=='Pawn').size()==4,'equal four-worker start')
 check(g.buildings.size()==2,'no gifted barracks')
 g.buildings[0].hp=100000 # Keep this economy fixture alive while testing later production.
 simulate(100)
 print('BASELINE ',g.enemy_money,' gathered=',g.enemy_gathered,' trained=',g.enemy_trained,' attacks=',g.opponent.attacks)
 check(g.enemy_gathered>0,'enemy deposits real resources')
 check(g.gold==300 and g.wood==300,'enemy economy does not credit or spend player balance')
 check(g.opponent.owned('Barracks').size()>0,'enemy builds legal barracks')
 check(g.enemy_trained>=7,'enemy trains workers and army')
 check(g.opponent.attacks==0,'opening preparation window has no automatic sortie')
 simulate(85)
 check(g.opponent.attacks>0,'paid army assembles and marches')
 check(g.units.any(func(u):return u.team==1 and u.kind!='Pawn' and u.p.x<1000),'attacking army actually crosses the bridge')
 var defenders=g.units.filter(func(u):return u.team==1 and u.kind!='Pawn' and u.p.x>1600)
 var intruder=g.entity('Warrior',Vector2(2020,870));g.units.append(intruder)
 simulate(1.2)
 check((g.opponent.state=='Defending base' and defenders.any(func(u):return is_same(u.target,intruder))) or intruder.hp<intruder.max,'home defenders respond to an intruder')
 intruder.hp=0
 var b=g.opponent.owned('Barracks')[0]
 b.hp=0
 simulate(1.2)
 check(not g.buildings.has(b),'destroyed producer removed with queue')
 simulate(50)
 check(not g.opponent.owned('Barracks').is_empty(),'enemy rebuilds lost barracks')
 g.reset()
 for u in g.units:
  if u.team==1:u.hp=0
 g.enemy_money=Vector2i.ZERO
 simulate(65)
 check(g.enemy_trained==0 and g.enemy_gathered==0,'no workers or money means no free reinforcements')
 check(g.units.filter(func(u):return u.team==1).is_empty(),'timer never spawns free enemy army')
 g.reset();g.ai_enabled=false
 var enemy_home=g.buildings.filter(func(b):return b.team==1)[0]
 g.enemy_money=Vector2i.ZERO
 check(not g.economy.train('Pawn',enemy_home),'enemy cannot queue without payment')
 g.enemy_money=Vector2i(300,300)
 check(g.economy.train('Pawn',enemy_home) and g.enemy_money.x==250,'enemy queue pays the same worker cost')
 check(not g.economy.train('Pawn',enemy_home),'enemy queued worker reserves fifth population slot')
 g.reset();check(g.enemy_money==Vector2i(300,300) and g.opponent.attacks==0,'restart clears opponent state')
 print('OPPONENT AUDIT ', 'PASS' if failures.is_empty() else failures);quit(0 if failures.is_empty() else 1)
