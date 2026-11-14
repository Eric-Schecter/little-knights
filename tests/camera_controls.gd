extends SceneTree
func _initialize():call_deferred('run')
func run():
 var game=load('res://main.tscn').instantiate();root.add_child(game)
 await process_frame
 game.paused=false;game.ai_enabled=false
 if game.start_menu!=null:game.start_menu.start()
 var controls=game.camera_controls
 Input.action_press('camera_left');assert(controls.keyboard_direction()==Vector2.LEFT)
 Input.action_press('camera_up');assert(is_equal_approx(controls.keyboard_direction().length(),1.0))
 Input.action_release('camera_left');Input.action_release('camera_up')
 for binding in [['camera_left',KEY_A],['camera_right',KEY_D],['camera_up',KEY_W],['camera_down',KEY_S]]:
  var event=InputEventKey.new();event.physical_keycode=binding[1];assert(InputMap.action_has_event(binding[0],event))
 var key=InputEventKey.new();key.pressed=true;key.keycode=KEY_A;game._unhandled_input(key);assert(not game.attack_cursor)
 key.keycode=KEY_X;game._unhandled_input(key);assert(game.attack_cursor)
 key.keycode=KEY_ESCAPE;game._unhandled_input(key);assert(not game.attack_cursor)
 assert(controls.edge_direction(Vector2(0,450),Vector2(1440,900))==Vector2.LEFT)
 assert(controls.edge_direction(Vector2(-1,450),Vector2(1440,900))==Vector2.ZERO)
 assert(is_equal_approx(controls.edge_direction(Vector2(1,1),Vector2(1440,900)).length(),1.0))
 controls.center_minimap(game.minimap_rect().get_center())
 assert(game.cam.is_equal_approx(game.WORLD/2-game.field_rect().get_center()))
 var selected_before=game.selected.duplicate()
 var down=InputEventMouseButton.new();down.button_index=MOUSE_BUTTON_MIDDLE;down.pressed=true;down.position=Vector2(700,400)
 controls._input(down);assert(controls.panning)
 var before=game.cam
 var motion=InputEventMouseMotion.new();motion.relative=Vector2(40,20);motion.position=Vector2(740,420)
 controls._input(motion);assert(game.cam.is_equal_approx(before-Vector2(40,20)))
 assert(game.selected==selected_before)
 controls.cancel_pointer();assert(not controls.panning and not controls.inside)
 game.paused=true;before=game.cam;controls._input(down);controls.tick(1.0)
 assert(not controls.panning and game.cam==before)
 print('CAMERA PASS: edges, diagonal speed, outside bounds, minimap center, middle drag, selection preserved, focus cancellation, pause')
 quit()
