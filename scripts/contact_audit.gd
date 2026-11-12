extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g);g.set_process(false)
 var demo=load('res://scripts/blocking_demo.gd').new(g);demo.setup()
 var last={};var states={};var flips=0;var toggles=0;var distance=0.0;var max_step=0.0
 for frame in range(540):
  var old=demo.army.map(func(u):return u.p)
  g._process(1.0/60)
  for i in range(demo.army.size()):
   var u=demo.army[i];var delta=u.p-old[i]
   if frame>=300:
    distance+=delta.length();max_step=max(max_step,delta.length())
    if last.has(i) and delta.length()>0.1 and last[i].length()>0.1 and delta.dot(last[i])<0:flips+=1
    if states.has(i) and states[i]!=u.moving:toggles+=1
   last[i]=delta;states[i]=u.moving
 print('BASE FOCUS CONTACT: reversals=',flips,' move toggles=',toggles,' summed travel=',distance,' max step=',max_step)
 quit(0 if flips==0 and toggles==0 and max_step<0.1 else 1)
