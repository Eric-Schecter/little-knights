extends SceneTree
var g
var failures=[]
func _initialize():call_deferred('run')
func check(ok,text):
 if not ok:failures.append(text);push_error(text)
 else:print('PASS: '+text)
func step(seconds):
 for i in range(int(seconds*30)):g._process(1.0/30)
func run():
 g=load('res://main.tscn').instantiate();root.add_child(g);g.set_process(false);g.ai_enabled=false
 check(g.match_results.totals[0].workers==0 and g.match_results.totals[1].workers==0,'Initial workers are not counted as trained')
 var worker=g.units[0];worker.carry=9;worker.carry_kind='gold';worker.returning=true;worker.p=Vector2(360,595)
 var enemy=g.units[4];enemy.carry=12;enemy.carry_kind='wood';enemy.returning=true;enemy.p=Vector2(2050,795)
 step(1)
 check(g.match_results.totals[0].gold==9 and g.match_results.totals[1].wood==12,'Deliveries credited to correct team and resource')
 worker.carry=7;worker.returning=false;step(0.1)
 check(g.match_results.totals[0].gold==9,'Undelivered cargo excluded')
 var home=g.buildings[0]
 g.train('Pawn',home);g.economy.cancel(home,0)
 check(g.match_results.totals[0].workers==0 and g.match_results.totals[0].gold==9,'Cancellation and refund are not training or collection')
 g.train('Pawn',home);step(6)
 check(g.match_results.totals[0].workers==1,'Completed training counted once')
 var barracks=g.entity('Barracks',Vector2(1700,900),1);g.buildings.append(barracks)
 g.buildings.append(g.entity('House1',Vector2(1900,1100),1));g.nav_dirty=true
 g.economy.train('Warrior',barracks);step(9)
 check(g.match_results.totals[1].army==1 and g.match_results.totals[0].army==0,'Military training is recorded separately for its owning team')
 var soldier=g.entity('Warrior',Vector2(800,500));g.units.append(soldier)
 g.damage(soldier,1000);g.damage(soldier,1000);g.damage(enemy,1000)
 var site=g.entity('House1',Vector2(900,900),1);site.progress=0.2;g.buildings.append(site);g.damage(site,1000)
 step(0.1)
 check(g.match_results.totals[0].army_losses==1 and g.match_results.totals[1].worker_losses==1 and g.match_results.totals[1].buildings==1,'Losses separated by category, including unfinished buildings; no duplicate deaths')
 var red_home=g.buildings.filter(func(b):return b.team==1 and b.kind=='Castle')[0]
 g.damage(red_home,9999);step(0.1)
 var saved=g.match_results.snapshot.duplicate(true);var seconds=g.time;var gold=g.gold
 check(g.outcome=='VICTORY' and g.match_results.overlay.visible and saved.teams[1].buildings==2,'Victory shows summary including final Town Center loss')
 step(3);g.train('Pawn',home);g.economy.cancel(home,0)
 var key=InputEventKey.new();key.pressed=true;key.keycode=KEY_SPACE;g._unhandled_input(key)
 check(g.time==seconds and g.gold==gold and not g.paused and g.match_results.snapshot==saved,'End screen freezes time, transactions, gameplay shortcuts and statistics')
 # Actual review and reopen buttons.
 for child in g.match_results.overlay.get_children():
  if child is Button and child.text=='Review battlefield':child.pressed.emit()
 check(not g.match_results.overlay.visible and g.match_results.reopen.visible,'Review keeps results available')
 g.match_results.reopen.pressed.emit()
 check(g.match_results.overlay.visible,'Reopen restores frozen summary')
 g.match_results.replay.pressed.emit()
 check(g.outcome=='' and g.gold==300 and g.time==0 and g.population()==4 and g.units.size()==8 and g.match_results.snapshot.is_empty() and not g.match_results.overlay.visible,'Replay button restores fresh match and hides summary')
 check(g.match_results.totals[0].gold==0 and g.match_results.totals[0].army_losses==0 and g.formations.is_empty() and g.shots.is_empty(),'Replay clears totals, formations and projectiles')
 g.damage(g.buildings[0],9999);step(0.1)
 check(g.outcome=='DEFEAT' and g.match_results.heading.text=='DEFEAT' and g.match_results.snapshot.teams[0].buildings==1,'Defeat has correct result and own building loss')
 g.match_results.replay.pressed.emit()
 for b in g.buildings:g.damage(b,9999)
 step(0.1)
 check(g.outcome=='DRAW' and g.match_results.heading.text=='DRAW','Same-tick destruction of both bases is a draw')
 print('RESULTS AUDIT failures=',failures);quit(0 if failures.is_empty() else 1)
