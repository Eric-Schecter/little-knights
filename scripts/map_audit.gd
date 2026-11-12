extends SceneTree
var g
var failures=[]
var count=0
func _initialize():call_deferred('run')
func check(ok,text):
 count+=1
 if not ok:failures.append(text);push_error(text)
func step(seconds):
 for i in range(int(seconds*30)):g._process(1.0/30.0)
func run():
 g=load('res://main.tscn').instantiate();root.add_child(g);g.set_process(false);g.ai_enabled=false
 check(g.land(Vector2(1200,290)) and g.land(Vector2(1200,690)),'Both crossings walkable')
 check(not g.land(Vector2(1200,470)) and not g.land(Vector2(1200,1000)),'River outside crossings remains blocked')
 var homes=g.resources.filter(func(r):return r.get('zone','')=='HOME')
 var rich=g.resources.filter(func(r):return r.get('zone','')=='RICH')
 check(homes.size()==2 and homes.all(func(r):return r.amount==900),'Equal limited home deposits')
 check(rich.size()==4 and rich.all(func(r):return r.amount==2600),'Two rich deposits on each bank')
 g.rebuild_nav()
 for y in [290,690]:
  var path=g.nav.get_point_path(g.nearest_cell(Vector2(850,y)),g.nearest_cell(Vector2(1550,y)))
  check(not path.is_empty() and Array(path).any(func(p):return abs(p.x-1200)<30 and abs(p.y-y)<40),'Path uses intended crossing '+str(y))
  check(g.economy.place('House1',Vector2(1200,y),[g.units[0]])==null,'No construction on crossing '+str(y))
 var worker=g.units[0]
 g.issue_order([worker],rich[0].p,rich[0]);step(35)
 check(g.gold>300 and rich[0].amount<2600,'Exposed mine can be harvested and delivered to home')
 g.reset();g.units.clear()
 var squad=[]
 for i in range(6):
  var u=g.entity('Warrior',Vector2(1800+(i%3)*42,760+int(i/3)*42),1);g.units.append(u);squad.append(u)
 g.opponent.send_squad(squad,true)
 var north=false;var illegal=false
 for i in range(1500):
  g.opponent.tick_routes();g._process(1.0/30)
  for u in squad:
   if abs(u.p.x-1200)<80:
    north=north or u.p.y<354
    illegal=illegal or not g.land(u.p)
 check(north and not illegal,'AI flank squad crosses north bridge without walking on water')
 check(squad.all(func(u):return u.p.x<1000),'AI completes waypoints and enters player bank')
 g.reset();g.ai_enabled=true
 g.buildings.append(g.entity('Tower',Vector2(960,690)));g.nav_dirty=true
 step(180)
 check(g.opponent.flank_attacks>0,'AI chooses flank when main crossing is defended')
 g.reset();g.ai_enabled=false
 for r in g.resources:
  if r.get('zone','')=='HOME':r.amount=0
 g.opponent.tick(2)
 check(g.units.any(func(u):return u.team==1 and u.job!=null and u.job.get('zone','')=='RICH'),'AI assigns exposed gold after home depletion')
 print('MAP AUDIT: ',count,' checks; failures=',failures)
 quit(0 if failures.is_empty() else 1)
