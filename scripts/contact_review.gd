extends SceneTree
class Review extends Node2D:
 var cam=Vector2.ZERO
 var time=0.0
 var art
 var elapsed=0.0
 func _ready():
  scale=Vector2(2,2)
  art=load('res://scripts/woodland_art.gd').new(self)
 func _process(_dt):
  elapsed+=1.0/30
  queue_redraw()
  if elapsed>12:get_tree().quit()
 func _draw():
  if art==null:return
  draw_texture_rect(art.grass,Rect2(0,0,720,450),false)
  draw_rect(Rect2(0,0,720,450),Color(0.48,0.57,0.35,0.27))
  for row in range(2):
   draw_string(ThemeDB.fallback_font,Vector2(20,25+row*225),'BEFORE / OLD CONTACT' if row==0 else 'AFTER / FOOTPRINT CONTACT',HORIZONTAL_ALIGNMENT_LEFT,-1,15,Color('#fff4d1'))
   for i in range(3):
    var key=['Blue_Castle','Blue_Tower','Tree3'][i]
    var cell=art.frames[key][0]
    var ground=Vector2(140+i*225,210+row*225)
    var shadow=cell.legacy_shadow if row==0 else cell.ground_shadow
    draw_texture_rect(shadow.cast,Rect2(ground+shadow.offset,shadow.size),false,Color(0.12,0.15,0.13,0.20))
    draw_texture_rect(shadow.contact,Rect2(ground+shadow.offset,shadow.size),false,Color(0.10,0.12,0.09,0.38 if row==0 else 0.68))
    var offset=Vector2(-(cell.bounds.position.x+cell.bounds.size.x/2.0),-cell.bounds.end.y)*cell.scale
    draw_texture_rect(cell.texture,Rect2(ground+offset,cell.size*cell.scale),false)
func _initialize():
 root.add_child(Review.new())
