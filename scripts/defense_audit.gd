extends SceneTree
var g
var failures=[]
func _initialize():call_deferred('run')
func check(ok,text):
 if not ok:failures.append(text);push_error(text)
 else:print('PASS: '+text)
func step(seconds):
 for i in range(int(seconds*60)):g._process(1.0/60)
func clean():
 g.reset();g.enemy_money=Vector2i.ZERO
 g.units.clear();g.resources.clear();g.time=160
func unit(kind,p,team):
 var u=g.entity(kind,p,team);u.mode='stop';g.units.append(u);return u
func run():
 g=load('res://main.tscn').instantiate();root.add_child(g);g.set_process(false)
 clean()
 var defender=unit('Warrior',Vector2(1860,780),1)
 var intruder=unit('Warrior',Vector2(1810,740),0)
 step(0.3)
 check(g.opponent.defense.active and is_same(defender.target,intruder),'Nearby guard reacts within one perception interval')
 var old=intruder.hp;step(1)
 check(intruder.hp<old,'Repeated defense updates do not cancel attack windup')
 clean()
 var raider=unit('Warrior',Vector2(950,690),1)
 var bait=unit('Warrior',Vector2(920,690),0)
 g.issue_order([raider],bait.p,bait)
 intruder=unit('Warrior',Vector2(1840,730),0)
 step(0.3)
 check(is_same(raider.target,intruder) and g.opponent.defense.recalls==1,'Already fighting expedition abandons distant target to defend home')
 check(g.opponent.attacks==0,'Defense suppresses new sorties')
 clean()
 raider=unit('Warrior',Vector2(1450,700),1);g.opponent.send_squad([raider],true)
 intruder=unit('Warrior',Vector2(1830,730),0)
 step(1.2)
 check(is_same(raider.target,intruder) and g.opponent.squads.all(func(s):return not g.contains_entity(s.members,raider)),'Recall removes soldier from old route so waypoints cannot overwrite defense')
 clean()
 var miner=unit('Pawn',Vector2(1470,410),1)
 var gold={'kind':'gold','p':Vector2(1470,410),'amount':200};g.resources.append(gold)
 miner.job=gold;miner.carry=9;miner.carry_kind='gold'
 defender=unit('Warrior',Vector2(1800,760),1)
 intruder=unit('Warrior',Vector2(1400,410),0)
 step(0.3)
 check(g.opponent.defense.active and is_same(defender.target,intruder),'Remote miner attack outside old 500px base radius calls defenders')
 check(miner.get('fleeing',false) and miner.job==null and miner.goal.distance_to(gold.p)>200 and miner.carry==9,'Threatened miner evacuates with cargo intact')
 g.damage(intruder,9999);step(6)
 check(not miner.get('fleeing',false) and is_same(miner.job,gold),'Miner resumes previous resource job after danger clears')
 check(not g.opponent.defense.active,'Threat clearance ends defensive alert after cooldown')
 clean()
 miner=unit('Pawn',Vector2(1470,410),1)
 var tower=g.entity('Tower',Vector2(1730,410),0);g.buildings.append(tower);g.nav_dirty=true
 step(0.3)
 check(miner.get('fleeing',false),'Miner also retreats from hostile tower range')
 clean()
 defender=unit('Warrior',Vector2(1800,760),1);defender.mode='move';defender.goal=defender.p
 step(0.3);check(defender.mode=='guard','New arrivals switch from movement to active guard')
 clean()
 intruder=unit('Warrior',Vector2(400,650),0)
 step(0.3);check(not g.opponent.defense.active,'Opponent does not react to distant unseen army')
 clean()
 defender=unit('Warrior',Vector2(1850,740),1)
 intruder=unit('Warrior',Vector2(1820,740),0)
 step(0.3);intruder.p=Vector2(400,650);intruder.goal=intruder.p
 step(6)
 check(not is_same(defender.target,intruder) and defender.goal.x>1500,'Defenders disengage instead of pursuing bait across the map')
 g.reset();check(not g.opponent.defense.active and g.opponent.defense.alerts==0,'Restart clears defense state')
 print('DEFENSE AUDIT failures=',failures);quit(0 if failures.is_empty() else 1)
