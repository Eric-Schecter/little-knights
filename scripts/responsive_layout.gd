extends Node
var g
var previous=Vector2.ZERO
func _init(game):g=game
func _ready():
 process_priority=-100
 apply()
func _process(_dt):
 if g.get_viewport_rect().size!=previous:apply()
func original(control):
 if not control.has_meta('layout_position'):control.set_meta('layout_position',control.position);control.set_meta('layout_size',control.size)
 return control.get_meta('layout_position')
func center_children(parent,delta):
 for child in parent.get_children():
  if child is Control:child.position=original(child)+delta
func apply():
 var size=g.get_viewport_rect().size
 if size.x<=0 or size.y<=0:return
 previous=size
 var extra=size-Vector2(1440,900)
 if g.hud!=null:
  for child in g.hud.get_children():
   if not child is Control:continue
   var pos=original(child)
   if child is ColorRect:
    child.position=pos+Vector2(0,extra.y if pos.y>=732 else 0)
    child.size=child.get_meta('layout_size')+Vector2(extra.x,0)
   else:
    var dx=extra.x if pos.x>=1300 else extra.x/2
    child.position=pos+Vector2(dx,extra.y if pos.y>=700 else (extra.y/2 if pos.y>72 else 0))
 if g.fog!=null:
  g.fog.world_view.get_parent().size=g.field_rect().size
  g.fog.mini_view.position=Vector2(23,755+extra.y)
 if g.start_menu!=null:
  var screen=g.start_menu.screen
  screen.size=size
  for child in screen.get_children():
   if child is TextureRect:child.size=size
   elif child is Control:child.position=original(child)+extra/2
 if g.settings_menu!=null:
  g.settings_menu.shade.size=size
  center_children(g.settings_menu.shade,extra/2)
 if g.match_results!=null and g.match_results.overlay!=null:
  center_children(g.match_results.overlay,extra/2)
  for child in g.match_results.overlay.get_children():
   if child is ColorRect and child.get_meta('layout_size').x==1440:child.position=Vector2.ZERO;child.size=size
  if g.match_results.reopen!=null:g.match_results.reopen.position=original(g.match_results.reopen)+Vector2(extra.x/2,0)
 g.cam=g.cam.clamp(Vector2(0,-72),g.camera_limit())
 g.queue_redraw()
