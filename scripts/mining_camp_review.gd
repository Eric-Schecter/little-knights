extends SceneTree
var g
var elapsed=0.0
var camp
var ore
var workers
var assigned=false
func _initialize():call_deferred('setup')
func setup():
 g=load('res://main.tscn').instantiate();root.add_child(g);g.ai_enabled=false;g.supply.enabled=false
 var site=g.random_map.expansions.filter(func(s):return s.team==0 and s.zone=='NATURAL')[0]
 workers=g.units.filter(func(u):return u.team==0 and u.kind=='Pawn').slice(0,3)
 for i in range(workers.size()):workers[i].p=site.camp+Vector2(-180,80+i*35)
 ore=g.resources.filter(func(r):return r.kind=='gold' and r.p==site.p)[0]
 g.cam=(site.camp-Vector2(580,350)).clamp(Vector2.ZERO,g.camera_limit())
 g.selected=workers;g.refresh_commands()
func _process(dt):
 if g==null:return false
 elapsed+=dt
 if elapsed>3 and camp==null:
  var site=g.random_map.expansions.filter(func(s):return s.team==0 and s.zone=='NATURAL')[0]
  camp=g.economy.place('Depot',site.camp,[workers[0]])
 if camp!=null and camp.progress>=1 and not assigned:
  assigned=true;g.issue_order(workers,ore.p,ore);g.selected=[camp];g.refresh_commands()
 if elapsed>38:
  print('CAMP REVIEW complete=',assigned,' gold=',g.gold,' gathered=',g.gathered)
  quit()
 return false
