extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g);g.set_process(false)
 for pair in [['Pawn',15],['Warrior',23],['Archer',24],['Tower',24],['House1',0]]:
  var e=g.entity(pair[0],Vector2(400,400));g.selected=[e];g.icon_hud.update()
  assert(g.base_attack(e)==pair[1])
  assert(g.icon_hud.attributes.attack.value.text==('—' if pair[1]==0 else str(pair[1])))
  e.hp=12;g.icon_hud.update();assert(g.icon_hud.hp_text.text.begins_with('12 /'))
  assert(g.icon_hud.mana_text.text=='—')
 g.selected=[];g.icon_hud.update()
 assert(not g.icon_hud.health.visible and not g.icon_hud.mana_icon.visible)
 print('ATTRIBUTES PASS: damage, noncombat buildings, live HP, absent mana and deselection')
 quit()
