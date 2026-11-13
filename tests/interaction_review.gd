extends SceneTree
func _initialize():call_deferred('run')
func run():
 DirAccess.make_dir_recursive_absolute('res://captures')
 var g=load('res://main.tscn').instantiate();root.add_child(g)
 await process_frame
 g.set_process(false);g.paused=false;g.ai_enabled=false;g.cam=Vector2.ZERO
 g.units.clear();g.buildings.clear();g.resources.clear();g.fog.observer=true
 var worker=g.entity('Pawn',Vector2(400,450));g.units.append(worker)
 for i in range(6):
  var u=g.entity('Cavalry',Vector2(500+i*100,450));u.moving=true;u.stride=float(i)/6;g.units.append(u)
 g.selected=[worker];g.refresh_commands();g.icon_hud.update();g.fog.update();g.fog.animate(1,true);g.queue_redraw()
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png('res://captures/interaction-review.png')
 print('INTERACTION VISUAL PASS')
 quit()
