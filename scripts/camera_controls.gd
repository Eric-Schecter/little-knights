extends Node
# All positions are in the game's logical canvas coordinates.
var g
var inside=false
var panning=false
var minimap_drag=false
func _init(game):g=game
func _ready():
 get_viewport().mouse_entered.connect(func():inside=true)
 get_viewport().mouse_exited.connect(cancel_pointer)
 get_window().focus_exited.connect(cancel_pointer)
func cancel_pointer():
 inside=false;panning=false;minimap_drag=false
func enabled():
 return not g.paused and g.outcome=='' and (g.start_menu==null or not g.start_menu.is_open()) and (g.settings_menu==null or not g.settings_menu.is_open())
func center_minimap(pos):
 var fraction=((pos-g.minimap_rect().position)/g.minimap_rect().size).clamp(Vector2.ZERO,Vector2.ONE)
 g.cam=(fraction*g.WORLD-g.field_rect().get_center()).clamp(Vector2(0,-72),g.camera_limit())
func _input(event):
 if not enabled():
  panning=false;minimap_drag=false;return
 if event is InputEventMouseMotion:
  inside=true
  if panning:
   g.cam=(g.cam-event.relative).clamp(Vector2(0,-72),g.camera_limit())
   get_viewport().set_input_as_handled()
  elif minimap_drag:
   center_minimap(event.position);get_viewport().set_input_as_handled()
 if event is InputEventMouseButton:
  if event.button_index==MOUSE_BUTTON_MIDDLE:
   if event.pressed and g.field_rect().has_point(event.position):
    panning=true;g.drag=false
   elif not event.pressed:panning=false
   if g.field_rect().has_point(event.position) or panning:get_viewport().set_input_as_handled()
  if event.button_index==MOUSE_BUTTON_LEFT:
   if event.pressed and g.minimap_rect().has_point(event.position):
    minimap_drag=true;g.drag=false;center_minimap(event.position);get_viewport().set_input_as_handled()
   elif not event.pressed and minimap_drag:
    minimap_drag=false;get_viewport().set_input_as_handled()
func edge_direction(pos,size):
 if not Rect2(Vector2.ZERO,size).has_point(pos):return Vector2.ZERO
 var margin=14.0
 return Vector2(float(pos.x>=size.x-margin)-float(pos.x<margin),float(pos.y>=size.y-margin)-float(pos.y<margin)).normalized()
func tick(dt):
 if not enabled():
  panning=false;minimap_drag=false;return
 if not get_window().has_focus():return
 var direction=Input.get_vector('ui_left','ui_right','ui_up','ui_down')
 if inside and not panning and not minimap_drag and direction==Vector2.ZERO:
  direction=edge_direction(g.get_global_mouse_position(),g.get_viewport_rect().size)
 if not panning and not minimap_drag:g.cam+=direction*550*dt
