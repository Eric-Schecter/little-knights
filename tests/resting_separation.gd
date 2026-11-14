extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g)
 await process_frame
 g.set_process(false);g.ai_enabled=false;g.paused=false;g.units.clear();g.buildings.clear();g.resources.clear();g.formations.clear();g.map_style='plains';g.nav_dirty=true
 for i in range(8):g.units.append(g.entity('Cavalry' if i%2 else 'Warrior',Vector2(500+(i%4)*8,500+int(i/4)*8)))
 for i in range(360):g._process(1.0/60)
 var settled=g.units.map(func(u):return u.p)
 var travel=0.0
 for i in range(180):
  var before=g.units.map(func(u):return u.p)
  g._process(1.0/60)
  for j in range(g.units.size()):travel+=g.units[j].p.distance_to(before[j])
 assert(travel<1.0,'Resting crowd keeps moving: '+str(travel))
 for i in range(g.units.size()):
  for j in range(i):assert(g.units[i].p.distance_to(g.units[j].p)>=g.blocking.radius(g.units[i])+g.blocking.radius(g.units[j])-2.5)
 g.issue_order(g.units,Vector2(850,600),null)
 for i in range(900):g._process(1.0/60)
 assert(g.units.all(func(u):return u.formation==-1),'Completed formation stays locked to slots')
 settled=g.units.map(func(u):return u.p)
 for i in range(120):g._process(1.0/60)
 for i in range(g.units.size()):assert(g.units[i].p.distance_to(settled[i])<.2)
 var first=g.units.slice(0,4);var second=g.units.slice(4,8)
 g.issue_order(first,Vector2(1050,650),null);g.issue_order(second,Vector2(1050,650),null)
 for i in range(1200):g._process(1.0/60)
 assert(g.units.all(func(u):return u.formation==-1),'Overlapping squads never release their slots')
 settled=g.units.map(func(u):return u.p)
 for i in range(180):g._process(1.0/60)
 for i in range(g.units.size()):assert(g.units[i].p.distance_to(settled[i])<.2,'Overlapping squads oscillate')
 print('RESTING SEPARATION PASS: mixed dense crowd settles without oscillation, bodies separate, formation moves and releases, final positions remain stable')
 quit()
