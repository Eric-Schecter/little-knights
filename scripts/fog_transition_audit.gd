extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g);g.set_process(false)
 var p=Vector2(1500,1050);var k=g.fog.key(p);var i=k.y*g.fog.COLS+k.x
 var u=g.entity('Warrior',p);g.units.append(u);g.fog.update();g.fog.animate(0.1)
 var revealed=g.fog.alpha[i]
 assert(revealed>0 and revealed<1,'Reveal must interpolate')
 g.fog.animate(1);assert(g.fog.alpha[i]==0,'Reveal finishes')
 u.p=Vector2(360,530);g.fog.update();g.fog.animate(0.1)
 assert(g.fog.alpha[i]>0 and g.fog.alpha[i]<0.48,'Loss of vision must interpolate')
 g.fog.animate(1);assert(abs(g.fog.alpha[i]-0.48)<0.001,'Explored region finishes dimmed')
 print('FOG TRANSITION PASS: reveal, loss, explored opacity');quit()
