extends SceneTree
func _initialize():call_deferred('run')
func run():
 var g=load('res://main.tscn').instantiate();root.add_child(g);g.set_process(false);g.ai_enabled=false
 for role in ['Pawn','Warrior','Archer']:
  for team in ['Blue','Red']:
   var bank=g.art.motions[team+'_'+role]
   assert(bank.walk.size()==6 and bank.action.size()==6)
   for cell in bank.walk+bank.action:
    assert(cell.texture.get_image().get_pixel(0,0).a<0.05,'Atlas background must be transparent')
    assert(cell.bounds.size.y>0)
 g.sfx.reset();g.paused=false
 assert(g.sfx.play('select'))
 assert(not g.sfx.play('select'),'Repeated selection must be rate limited')
 g.sfx.tick(0.3);assert(g.sfx.play('select'))
 assert(not g.sfx.play('hit',Vector2(-9999,-9999)),'Offscreen events must be silent')
 g.paused=true;assert(not g.sfx.play('train'),'Pause suppresses new sounds')
 g.paused=false;g.sfx.reset()
 var u=g.units[0];g.selected=[u]
 g.order(u.p+Vector2(20,0),null)
 assert(g.sfx.counts.get('command',0)==1,'One acknowledgement per player order')
 g.sfx.tick(1);g.issue_order([u],u.p,null)
 assert(g.sfx.counts.get('command',0)==1,'AI and internal orders stay silent')
 g.cam=u.p-Vector2(400,300);g.fog.visible[0][g.fog.key(u.p)]=true
 g.damage(u,9999);g.damage(u,9999)
 assert(g.sfx.counts.get('death',0)==1,'Death plays once, not for repeated damage')
 var b=g.buildings[0];g.cam=b.p-Vector2(400,300);g.fog.visible[0][g.fog.key(b.p)]=true
 g.damage(b,99999);g.damage(b,99999)
 assert(g.sfx.counts.get('collapse',0)==1,'Collapse plays once')
 assert(g.sfx.play('complete') and g.sfx.play('train'),'Production notifications are available offscreen')
 print('ANIMATION AUDIO PASS: 72 frames, transparent corners, cooldown, offscreen and pause gating')
 quit()
