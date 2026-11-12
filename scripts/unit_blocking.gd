extends RefCounted
const DIAMETER=24.0
const SKIN=0.03
var g
var contacts=0
func _init(game):g=game
func radius(u):return 18.0 if u.kind=='Cavalry' else 12.0
func clear_at(point,team,own_radius=12.0):
 for other in g.units:
  if other.hp>0 and other.team!=team and point.distance_squared_to(other.p)<pow(own_radius+radius(other),2):return false
 return true
func clip(start,delta,team,own_radius=12.0):
 var fraction=1.0
 var blocker=null
 var length2=delta.length_squared()
 if length2<0.0000001:return {'point':start,'blocker':null}
 for other in g.units:
  if other.hp<=0 or other.team==team:continue
  var offset=start-other.p
  var c=offset.length_squared()-pow(own_radius+radius(other),2)
  var approach=offset.dot(delta)
  if c<0:
   # Legacy/spawn overlaps can separate, never move deeper into the opponent.
   if approach<0:fraction=0.0;blocker=other
   continue
  if approach>=0:continue
  var discriminant=approach*approach-length2*c
  if discriminant<0:continue
  var hit=(-approach-sqrt(discriminant))/length2
  if hit>=0 and hit<fraction:fraction=max(0.0,hit-SKIN/sqrt(length2));blocker=other
 return {'point':start+delta*fraction,'blocker':blocker}
func move(u,destination,slide=true):
 # Formation anchors are virtual, not bodies.
 if not g.contains_entity(g.units,u):u.p=destination;return
 var start=u.p
 var result=clip(start,destination-start,u.team,radius(u))
 if result.blocker!=null:contacts+=1
 var point=result.point
 if slide and result.blocker!=null:
  var normal=(point-result.blocker.p).normalized()
  var rest=destination-point
  var tangent=rest-normal*min(0.0,rest.dot(normal))
  # Head-on contact rests instead of inventing alternating avoidance directions.
  if tangent.length()>rest.length()*0.25:
   var slid=clip(point,tangent,u.team,radius(u)).point
   if g.segment_clear(point,slid):point=slid
 if g.walkable(point):u.p=point
