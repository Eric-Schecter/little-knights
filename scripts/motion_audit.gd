extends SceneTree
func _initialize():call_deferred('run_audit')
func run_audit():
 var g=load('res://main.tscn').instantiate();root.add_child(g);g.set_process(false);g.ai_enabled=false
 g.setup_formation_video()
 var last={};var switches=0;var faces=0;var min_speed=1000.0;var max_speed=0.0
 for frame in range(1200):
  if frame==480:g.order(Vector2(1490,680),null)
  var before=[]
  for u in g.units:before.append(u.p)
  g._process(1.0/60)
  for i in range(g.units.size()):
   var u=g.units[i]
   if frame>=600 and frame<900:
    var speed=u.p.distance_to(before[i])*60
    min_speed=min(min_speed,speed);max_speed=max(max_speed,speed)
    if last.has(i):
     if last[i][0]!=u.moving:switches+=1
     if last[i][1]!=u.face:faces+=1
   last[i]=[u.moving,u.face]
 assert(switches==0, 'Continuous formation marching must not toggle move/idle')
 assert(min_speed>50 and max_speed<75, 'Following speed must stay continuous')
 print('MOTION AUDIT: 5s x 12 units, move/idle switches=',switches,' facing switches=',faces,' speed range=',min_speed,'..',max_speed)
 quit()
