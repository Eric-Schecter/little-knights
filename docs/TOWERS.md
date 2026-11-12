# Arrow and cannon towers (current)

Only two branches remain. Both preserve the original narrow stone tower, wooden
balcony, pyramidal tiled roof, banner and flag. Arrow towers add balcony crossbows;
cannon towers add one short iron gun and balcony braces. The previous squat
bastion, giant ballista, lookout and slow-arrow branches are no longer selectable.

Select a completed basic Arrow Tower. Choose Arrow Tower (90 gold / 70 wood) or
Cannon Tower (120 gold / 90 wood). First upgrade: 15 seconds. Each has a second
level for 140 gold / 100 wood, taking 20 seconds. Branch choice is permanent.
Upgrading pauses firing, preserves HP and max HP, and is lost if the tower dies.

Arrow: 14 damage, 0.65-second cycle, range 245; level 2 adds a second arrow after
0.16 seconds. Cannon: 42 damage, 2.3-second cycle, range 300; blast radius 42 at
level 1 and 60 at level 2. Cannonballs damage nearby enemy units, never allies,
and resolve armor separately per victim. Both towers have vision 400; no slow.
Basic unupgraded tower remains 24 damage / 1.2 seconds / range 260.

Cannon firing uses a round iron projectile, arcing visual flight, muzzle smoke,
blast dust and dedicated low cannon/report audio; arrows keep slim projectiles
and mechanical release sounds. New atlas: assets/knights/towers-classic-v3.png.
It supplies sprites, shadows, portraits and choice icons with the original shape.

Checks: tower_audit.gd covers exactly two choices, payment, irreversible branch,
HP preservation, double arrows, real cannon impact splash, radius, friendly-fire
exclusion and launch/impact audio dispatch. tower_review.gd records paid upgrades
and identical groups of three swordsmen plus one crossbowman.
