extends SceneTree
func _initialize():call_deferred('run')
func run():
 DirAccess.make_dir_recursive_absolute("res://captures")
 var g=load('res://main.tscn').instantiate();root.add_child(g)
 await process_frame
 g.paused=true;g.ai_enabled=false
 g.start_menu=load('res://scripts/start_menu.gd').new(g);g.add_child(g.start_menu)
 for spec in [['wide',Vector2i(1600,900)],['narrow',Vector2i(900,1000)]]:
  root.size=spec[1]
  await process_frame
  await process_frame
  g.responsive_layout.apply()
  var size=g.get_viewport_rect().size
  var scale=root.get_final_transform().get_scale()
  assert(is_equal_approx(scale.x,scale.y),'Uniform scaling')
  assert(is_equal_approx(size.x/size.y,float(root.size.x)/root.size.y),'Viewport fills window')
  assert(g.fog.world_view.get_parent().size.is_equal_approx(g.field_rect().size))
  assert(g.minimap_rect().end.y<size.y)
  assert(g.commands.position.y+132<size.y)
  g.start_menu.screen.show();g.queue_redraw()
  await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png('res://captures/responsive-'+spec[0]+'-cover.png')
  g.start_menu.screen.hide();g.selected=[g.units[0]];g.refresh_commands();g.settings_menu.open()
  g.responsive_layout.apply()
  await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png('res://captures/responsive-'+spec[0]+'-game.png')
  g.settings_menu.close()
  print('RESPONSIVE PASS ',spec[0],': viewport=',size,' scale=',scale)
 quit()
