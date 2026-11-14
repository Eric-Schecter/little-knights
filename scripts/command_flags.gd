extends Node2D
var g
func _init(game):g=game;z_index=10
func _process(_dt):queue_redraw()
func _draw():
 if g.outcome!='':return
 for fx in g.effects:
  if not fx.get('command_flag',false):continue
  var p=fx.p-g.cam
  if not g.field_rect().grow(-4).has_point(p):continue
  var alpha=clampf(fx.life/0.25,0,1)
  var age=0.9-fx.life
  var drop=-10*pow(maxf(0,1-age/0.14),2)
  draw_flag(p,alpha,age,drop,fx.get('attack',false))
 for b in g.selected:
  if not g.contains_entity(g.buildings,b) or b.kind not in ['Castle','Barracks','Workshop'] or b.get('rally_disabled',false):continue
  var leader=b.get('rally_unit')
  var point=leader.p if leader!=null and leader.hp>0 else b.rally
  var age=g.time-b.get('rally_set_at',-1.0)
  var drop=-10*pow(maxf(0,1-age/0.14),2)
  draw_flag(point-g.cam,1.0,g.time,drop,false)
func draw_flag(p,alpha,age,drop,attack):
 if not g.field_rect().grow(-4).has_point(p):return
 var top=p+Vector2(0,-34+drop)
 var color=Color('#ef926c') if attack else Color('#86d5b8')
 color.a=alpha
 draw_line(p+Vector2(-4,1),p+Vector2(5,1),Color(0.05,0.12,0.1,alpha*.8),3,true)
 draw_line(p,top,Color(0.12,0.18,0.15,alpha),4,true)
 draw_line(p,top,Color(0.97,0.88,0.65,alpha),2,true)
 var wave=sin(age*12)*2
 var cloth=PackedVector2Array([top+Vector2(1,1),top+Vector2(25,4+wave),top+Vector2(18,11+wave),top+Vector2(25,17+wave),top+Vector2(1,14)])
 draw_colored_polygon(cloth,color)
 cloth.append(cloth[0]);draw_polyline(cloth,Color(.12,.23,.2,alpha),1.4,true)
