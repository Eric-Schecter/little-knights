extends SceneTree
var failures=[]
func check(ok,text):
 if not ok:failures.append(text);push_error(text)
 else:print('PASS: '+text)
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g);g.set_process(false)
 var minimum_gap=INF
 var driver=load('res://scripts/match_driver.gd').new(g)
 for i in range(27000):
  driver.tick(1.0/30);g._process(1.0/30)
  for a in g.units:
   if a.team!=0:continue
   for b in g.units:
    if b.team==1:minimum_gap=min(minimum_gap,a.p.distance_to(b.p))
  if i%1800==0:print('PACE ',int(g.time),' army=',g.population(),'/',g.population(1),' gold=',g.gold,'/',g.enemy_money.x,' assaults=',driver.assaults,' castle=',g.buildings.filter(func(b):return b.kind=='Castle').map(func(b):return b.hp))
  if g.outcome!='':break
 var report=driver.report()
 print('PACE RESULT ',JSON.stringify(report))
 print('MATCH MINIMUM ENEMY GAP ',minimum_gap)
 check(minimum_gap>=23.99,'Enemy bodies stay separated throughout the complete match')
 check(g.blocking.contacts>0,'Full match exercises body blocking')
 var history=g.opponent.attack_history
 check(g.outcome=='VICTORY','Complete normal-cost match reaches victory')
 check(g.time>=480 and g.time<=720,'Conservative review match ends within 8 to 12 minutes')
 check(not history.is_empty() and history[0].time>=150 and history[0].time<155 and history[0].size==3,'First sortie respects preparation window and small wave')
 for i in range(1,history.size()):check(history[i].time-history[i-1].time>=60,'No back-to-back sortie burst')
 check(history.any(func(w):return w.size==5),'Midgame increases pressure with paid army')
 check(driver.expansions>0 and driver.first_contact>150,'Expansion and first contact occur in complete match')
 check(g.enemy_gathered>3000 and g.enemy_trained>20,'Opponent sustains real gathering and replenishment')
 g.reset()
 check(g.outcome=='' and g.gold==300 and g.population()==4 and g.opponent.attack_history.is_empty(),'Restart clears pacing history and restores fresh match')
 print('PACE AUDIT: failures=',failures)
 quit(0 if failures.is_empty() else 1)
