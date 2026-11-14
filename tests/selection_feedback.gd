extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g)
 await process_frame
 g.set_process(false);g.ai_enabled=false;g.paused=false;g.units.clear();g.buildings.clear();g.resources.clear();g.nav_dirty=true
 var soldier=g.entity('Warrior',Vector2(500,418))
 var worker=g.entity('Pawn',Vector2(450,400))
 var enemy=g.entity('Warrior',Vector2(650,418),1)
 g.units=[soldier,worker,enemy];g.cam=Vector2(100,0);g.drag_screen=Vector2(400,400);g.drag_start=Vector2(400,400)
 g.finish_selection(Vector2(400,400));assert(g.selected.size()==1 and is_same(g.selected[0],soldier),'Camera travel cannot turn a click into a box')
 g.drag_screen=Vector2(300,350);g.finish_selection(Vector2(430,450));assert(g.selected.size()==1 and is_same(g.selected[0],soldier),'Army box excludes incidental workers')
 g.drag_screen=Vector2(330,375);g.finish_selection(Vector2(365,425));assert(g.selected.size()==1 and is_same(g.selected[0],worker),'Worker-only box remains usable')
 g.drag_screen=Vector2(400,400);g.finish_selection(Vector2(400,400),true);assert(g.selected.size()==2,'Explicit additive selection is preserved')
 g.drag=true;g.cancel_selection_drag();assert(not g.drag)
 g.selected=[soldier];g.order(enemy.p,enemy)
 assert(g.effects.any(func(f):return f.get('attack_order',false) and is_same(f.target,enemy)))
 assert(g.sfx.counts.get('attack_order',0)==1)
 g.order(enemy.p,enemy);assert(g.sfx.counts.attack_order==1,'Rapid orders must not stack horn calls')
 var a={'p':Vector2(600,500),'render_id':2};var b={'p':Vector2(620,500),'render_id':1}
 assert(g.render_before(a,b) and not g.render_before(b,a))
 b.p=a.p;assert(g.render_before(b,a) and not g.render_before(a,b))
 var tree={'kind':'wood','p':Vector2(500,460),'amount':100};g.resources=[tree]
 g.fog.observer=true;g.fog.update();g.fog.animate(1,true)
 g.update_tree_fades(.016);assert(tree.canopy_alpha<1 and tree.canopy_alpha>.45)
 soldier.p.x=555;worker.p=Vector2(100,100);g.update_tree_fades(.016);assert(tree.canopy_obscured,'Small boundary movement does not flicker')
 soldier.p.x=570;g.update_tree_fades(.016);assert(not tree.canopy_obscured)
 print('SELECTION FEEDBACK PASS: camera-safe click, army/worker boxes, explicit add, drag cancellation, attack cue and sound cooldown, stable tree depth, smooth hysteresis')
 quit()
