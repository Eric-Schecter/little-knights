extends SceneTree
var g
var failures=[]
var count=0
func _initialize():call_deferred('run')
func check(condition,description):
 count+=1
 if not condition:failures.append(description);push_error(description)
func step(seconds):
 for i in range(int(seconds*60)):g._process(1.0/60)
func clean():
 g.reset();g.resources.clear();g.units=g.units.filter(func(u):return u.team==0);g.raid=999
func run():
 g=load('res://main.tscn').instantiate();root.add_child(g);g.set_process(false);g.ai_enabled=false
 clean()
 var u=g.units[0];var source={'kind':'gold','p':Vector2(240,720),'amount':7}
 g.resources.append(source);g.selected=[u];g.order(source.p,source);var start=g.gold;step(15)
 check(g.gold==start+7 and source.amount==0 and u.carry==0,'Partial final cargo delivered exactly; resource cannot become negative')
 check(u.job==null and u.work_state=='Idle','Worker becomes idle when no nearby source exists')
 clean();u=g.units[0]
 var first={'kind':'gold','p':Vector2(240,720),'amount':3};var second={'kind':'gold','p':Vector2(330,750),'amount':60}
 g.resources.append_array([first,second]);g.selected=[u];g.order(first.p,first);step(9)
 check(first.amount==0 and u.job==second,'Depletion automatically chooses nearby same resource')
 check(g.gold>300,'Auto-switch preserves first cargo delivery')
 clean();u=g.units[0];u.carry=9;u.carry_kind='gold'
 var tree={'kind':'wood','p':Vector2(230,720),'amount':60};g.resources.append(tree)
 g.selected=[u];g.order(tree.p,tree);step(10)
 check(g.gold==309,'Switching from gold to wood deposits gold as gold')
 check(g.wood>=300 and u.carry_kind=='wood','New gathering uses the correct resource kind')
 u.carry=15;u.returning=true;g.stop_selected();var stopped=u.p;step(1)
 check(u.p.distance_to(stopped)<1 and u.carry==15,'Stop overrides worker return order without deleting cargo')
 clean();u=g.units[0];g.selected=[u]
 var before=g.wood
 check(g.economy.place('House1',g.buildings[0].p,[u])==null and g.wood==before,'Overlapping building rejected without spending')
 check(g.economy.place('House1',Vector2(1090,500),[u])==null,'Foundation over shoreline rejected')
 check(g.economy.place('House1',Vector2(1200,680),[u])==null,'Bridge construction rejected')
 check(g.economy.place('House1',u.p,[u])==null,'Foundation overlapping units rejected')
 g.resources.append({'kind':'wood','p':Vector2(620,480),'amount':30})
 check(g.economy.place('House1',Vector2(620,480),[u])==null,'Foundation overlapping resources rejected')
 g.resources.clear();var house=g.economy.place('House1',Vector2(620,480),[u])
 check(house!=null and g.wood==before-80 and g.capacity()==5,'Construction spends once; unfinished house gives no capacity')
 step(20);check(house.progress>=1 and g.capacity()==10,'Worker travel and construction finish, enabling population')
 check(g.sfx.counts.get('complete',0)==1,'Actual construction emits one completion notification')
 clean();u=g.units[0];var b=g.economy.place('Barracks',Vector2(620,650),[u])
 check(not g.train('Warrior',b) and b.queue.is_empty(),'Training locked during construction')
 step(18);check(b.progress>=1,'Barracks completes through worker labor')
 g.buildings.append(g.entity('House1',Vector2(700,450)))
 var gold_before=g.gold;var wood_before=g.wood
 check(g.train('Warrior',b) and g.train('Archer',b),'Both unit types can be queued')
 check(g.gold==gold_before-140 and g.wood==wood_before-30 and g.population()==6,'Queue payment and population reservations exact')
 step(2);var progress=b.train
 check(g.economy.cancel(b,1) and b.train==progress and g.gold==gold_before-80 and g.wood==wood_before,'Cancel waiting item refunds exactly and preserves active progress')
 check(g.economy.cancel(b,0) and b.train==0 and g.gold==gold_before and g.population()==4,'Cancel active item refunds, resets progress and releases population')
 check(not g.economy.cancel(b,0) and g.gold==gold_before,'Cannot double-refund an empty queue')
 g.selected=[b];g.order(Vector2(870,660),null);g.train('Warrior',b);step(12)
 var soldier=g.units.filter(func(v):return v.team==0 and v.kind=='Warrior')[0]
 check(soldier.p.distance_to(b.rally)<20,'Trained unit reaches rally point')
 check(g.sfx.counts.get('train',0)==1,'Actual training emits one ready notification')
 clean();b=g.buildings[0];var savings=g.gold
 check(g.train('Pawn',b),'Last free population can be reserved')
 check(not g.train('Pawn',b) and g.gold==savings-50,'Population cap rejects training without charging')
 clean();b=g.entity('Barracks',Vector2(620,650));g.buildings.append(b)
 g.buildings.append(g.entity('House1',Vector2(700,450)));g.gold=1000
 for i in range(5):check(g.train('Warrior',b),'Queue slot %d accepted'%i)
 var money=g.gold;check(not g.train('Warrior',b) and g.gold==money,'Queue limit rejects sixth item without charge')
 g.buildings[-1].hp=0;step(1)
 var elapsed=b.train;step(1);check(b.train==elapsed,'Training waits when destroyed housing leaves population over cap')
 clean();b=g.entity('Barracks',Vector2(620,650));g.buildings.append(b)
 g.buildings.append(g.entity('House1',Vector2(700,450)))
 g.selected=[b];g.train('Warrior',b);g.train('Archer',b);g.update_economy_hud()
 check(g.queue_row.get_child_count()==2,'Visible queue cards match paid queue')
 var paid=g.gold;g.queue_row.get_child(1).pressed.emit();g.update_economy_hud()
 check(b.queue.size()==1 and g.gold==paid+60 and g.queue_row.get_child_count()==1,'Queue button signal cancels the intended waiting item and refreshes UI')
 g.queue_row.get_child(0).pressed.emit();g.update_economy_hud()
 check(b.queue.is_empty() and g.queue_row.get_child_count()==0,'Active card button clears queue without stale UI')
 check(g.pick(b.p-Vector2(0,85),true)==b,'Building roof is selectable')
 var canopy={'kind':'wood','p':Vector2(850,350),'amount':50};g.resources.append(canopy)
 g.units.append(g.entity('Pawn',canopy.p+Vector2(100,0)));g.fog.update()
 check(g.pick(canopy.p-Vector2(0,65),false)==canopy,'Tree canopy accepts gathering target')
 print('ECONOMY AUDIT: ',count,' checks; failures=',failures)
 quit(0 if failures.is_empty() else 1)
