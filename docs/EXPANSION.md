# Foundry & Siege — first playable content expansion

Workers can build Blacksmith (120 wood) and Siege Workshop (200 wood).
Barracks now trains Spearmen (55 gold, 20 wood, 7 seconds): 110 HP,
18 base damage, 42 contact range, +9 damage against Swordsmen (the former unmounted Knight).
Workshop trains Catapults (140 gold, 100 wood, 16 seconds): 160 HP,
55 movement speed, 330 range, 75 minimum range, 3.2 second attack interval.
Stone impacts deal 24 to troops / 90 to buildings in a 55-pixel radius,
plus attack upgrades, minus armor; no friendly damage. Stones hit their
original landing location, allowing moving troops to dodge.
Spearmen and Catapults each reserve one population. Mounted Knights reserve two.

Blacksmith offers two levels each of attack (+3 per level) and armor
(-2 incoming damage per level, minimum 1 damage). Military units only:
Swordsman, Crossbowman, Spearman, Catapult, mounted Knight. Workers, towers and other
buildings do not receive upgrades. Existing and future troops benefit.
Level 1: 100 gold, 80 wood, 20 seconds. Level 2: 175 gold, 130 wood,
30 seconds. One research per forge, no duplicate branch across forges.
Research is lost without refund if its building is destroyed; completed
upgrades persist. Restart clears both teams' research.

Opponent builds advanced production when resources permit after 120/180
seconds, mixes Spearmen into its infantry, researches upgrades, and aims
for at most two active catapults. Review player follows the same rules.
Q/E research attack/armor in the selected Blacksmith; Q trains a Catapult
in the selected Workshop. Other actions remain available as icon buttons.

Validation: scripts/expansion_audit.gd (--classic) covers real construction,
paid timed research, caps, ownership, retroactive bonuses, training,
siege splash, friendly exclusion, minimum range and reset.
The staged scripts/expansion_review.gd starts with completed buildings and
extra resources for inspection; its research, training and combat run at
normal speed. Full match uses --supply-video and normal starting resources.

Art: assets/knights/expansion.png and spearman-motion.png generated with
ImageGen using the existing Little Knights building atlas as style reference.
Expansion: four columns (Blacksmith, Workshop, Spearman, Catapult), two rows
(teal/coral). Spearman animation: six columns and four rows, teal walk/thrust
and coral walk/thrust. Runtime slicing preserves original generated assets.
Catapult currently uses a single sprite with recoil and ballistic stone effects;
a dedicated mechanical animation is a future polish task.

## Mounted Knight addition

The old Warrior is now displayed as Swordsman; internal keys remain compatible.
Cavalry is displayed as Knight, with its own horse/rider portrait and six-frame
trot and mounted-sword sequences for both teams. Trained at Barracks after a
completed friendly Blacksmith: 125 gold, 40 wood, 12 seconds, 2 population.
190 HP, 28 damage, 2 innate armor, 140 solo movement speed, range 24.
Pure cavalry formations march faster; mixed formations stay together.
Spearmen deal +18 against mounted Knights before armor, versus +9 against
Swordsmen. Blacksmith upgrades affect cavalry normally. Enemy collision
radius is 18 rather than infantry's 12, preventing high-speed tunnelling.

Art source: ImageGen exec-386b0450-019a-465a-b731-90d2bc03451c.png;
reference expansion.png. Six columns, teal trot/attack and coral trot/attack.
The initial image's residual background was removed by a second ImageGen edit.
No direct borrowing of Warcraft art or audio.

scripts/cavalry_audit.gd covers unlock, payments/refunds, two-pop reservation,
training, upgrades, spear counter, speed, stable arrival and collision.
scripts/cavalry_review.gd is a staged normal-speed demo, with one initial
rider and one rider paid for and trained normally.
