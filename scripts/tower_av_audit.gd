extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g);g.set_process(false);g.ai_enabled=false;g.supply.enabled=false;g.units=[];g.resources=[];g.cam=Vector2.ZERO
 for i in range(2):
  var key=['arrow','cannon'][i]
  var tower=g.entity('Tower',Vector2(300+i*400,450));tower['tower_branch']=key;tower['tower_level']=2;g.buildings.append(tower)
  var enemy=g.entity('Cavalry',tower.p+Vector2(0,-100),1);g.units.append(enemy);g.fog.update()
  g.fire(tower,enemy,g.base_attack(tower))
  assert(g.shots[-1].tower_branch==key and g.shots[-1].muzzle_height>60)
  assert(g.sfx.counts.get('tower_rapid' if key=='arrow' else 'tower_cannon',0)>0,'Branch audio is actually dispatched')
  assert(g.art.frames.has(g.art.entity_key(tower)))
  assert(g.icon_hud.icons.has('Tower_'+key))
 print('TOWER AV PASS: separate sprites, portraits, muzzle heights, projectile tags and two dispatched audio events');quit()
