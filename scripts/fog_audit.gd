extends SceneTree
var g
var failures=[]
func _initialize():call_deferred('run')
func check(ok,label):
 if not ok:failures.append(label)
 print(('PASS ' if ok else 'FAIL ')+label)
func run():
 g=load('res://main.tscn').instantiate();root.add_child(g);g.set_process(false);g.ai_enabled=false
 check(g.fog.sees(0,Vector2(360,530)),'Own base visible')
 check(not g.fog.known(0,Vector2(2050,730)),'Enemy base unexplored')
 check(g.pick(Vector2(2050,700),false)==null,'Hidden base cannot be clicked')
 var scout=g.entity('Warrior',Vector2(1800,730));g.units.append(scout);g.fog.update()
 check(g.fog.sees(0,Vector2(2050,730)),'Scout reveals enemy base')
 check(g.pick(Vector2(2050,700),false)!=null,'Visible base can be clicked')
 scout.target=g.buildings[1];scout.p=Vector2(400,530);g.fog.update();g._process(1.0/60)
 check(not g.fog.sees(0,Vector2(2050,730)) and g.fog.known(0,Vector2(2050,730)),'Explored area darkens after scout leaves')
 check(scout.target==null,'Hidden target is not tracked')
 check(not g.fog.sees(1,Vector2(360,530)),'Enemy has independent vision')
 g.reset()
 check(not g.fog.known(0,Vector2(2050,730)),'Restart clears exploration')
 print('FOG AUDIT failures=',failures);quit(0 if failures.is_empty() else 1)
