extends RefCounted
var g
var elapsed=0.0
var squad=[]
var ordered=false
func _init(game):g=game
func setup():
 g.reset();g.ai_enabled=false;g.cam=Vector2(0,230)
 for spec in [['Barracks',Vector2(650,470),0],['House1',Vector2(620,880),0],['Tower',Vector2(950,580),0],['Barracks',Vector2(1790,520),1],['House1',Vector2(2150,1040),1],['Tower',Vector2(1490,600),1]]:
  g.buildings.append(g.entity(spec[0],spec[1],spec[2]))
 for i in range(6):
  var u=g.entity('Warrior' if i<4 else 'Archer',Vector2(760+(i%3)*46,660+int(i/3)*46));u.mode='stop';g.units.append(u);squad.append(u)
 for i in range(4):
  var u=g.entity('Warrior' if i<3 else 'Archer',Vector2(1530+(i%2)*46,680+int(i/2)*46),1);u.mode='guard';g.units.append(u)
 for u in g.units:
  if u.kind=='Pawn':
   var r=g.resources.filter(func(e):return e.kind=='gold' and ((u.team==0 and e.p.x<500) or (u.team==1 and e.p.x>2100)))
   if not r.is_empty():g.issue_order([u],r[0].p,r[0])
 g.nav_dirty=true;g.fog.reset();g.selected=squad.duplicate();g.refresh_commands()
func tick():
 elapsed+=1.0/30
 var shadow_review="--shadow-review" in OS.get_cmdline_user_args()
 if shadow_review:g.art.shadows_enabled=elapsed>=4
 if elapsed>8 and not ordered:
  ordered=true;g.issue_order(squad,Vector2(2050,730),null,'attack_move')
 if elapsed>10:
  var alive=squad.filter(func(u):return u.hp>0)
  if not alive.is_empty():
   var focus=Vector2.ZERO
   for u in alive:focus+=u.p
   focus/=alive.size()
   g.cam=g.cam.lerp((focus-Vector2(620,360)).clamp(Vector2(0,-72),Vector2(1080,740)),0.05)
 g.stats.text=('SHADOW REVIEW / '+('BEFORE' if elapsed<4 else 'AFTER')) if shadow_review else 'LITTLE KNIGHTS / 2D ART PASS'
 g.message.text='2D sprites / concept style | Staged preview / normal speed | Teal vs Coral'
 if elapsed>38:g.get_tree().quit()
