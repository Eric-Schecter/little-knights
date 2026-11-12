# Current victory rule

Destroy the enemy Town Center to win. Control-score victory has been removed.
Both neutral camps now grant 12 gold + 6 wood per uncontested 10 seconds;
occupation never ends a match. Scores in historical reviews below describe old
rules only. Armies of at least six advance toward the opposing starting base
after securing their objective; combat target acquisition still obeys fog.
The review runner waits for actual base destruction instead of declaring a result
at a timer threshold.

# Seeded river-valley maps

Normal games use a 3200 × 2200 battlefield (previously 2400 × 1400,
about 2.1 times the area), with a new layout on restart and no consecutive
repeat of the terrain family. The seed appears beneath the logo. Two-bridge
river, three-bridge river and open plains have different crossing choices.
Generation version 3 changes the layout associated with old seeds.

Both teams have mirrored town centers, starting armies and resources.
Each side has a 1200-gold home mine, two 2200-gold natural expansions,
a 3000-gold outer pocket, and two exposed 4000-gold rich mines near the center.
These are neutral resources: either player can occupy or raid them.
The outer pocket trades a longer trip for distance from the central battlefield;
rich mines offer more reserves but are easier for the opponent to contest.
Six starter trees, four trees per expansion and additional random forests
provide lumber. Every expansion has a clear, path-accessible building pad.

Workers can build a **Mining Camp** for 100 wood. It has 450 HP and accepts
gold and wood deliveries, shortening worker travel without passive income.
Only completed camps receive cargo; destroyed camps fall back to the nearest
surviving drop-off point. Protecting the camp and its workers matters.
With six workers, the AI attempts a natural expansion after 100 seconds or
when its home mine falls below 450 gold; it respects construction, wood and
visible enemy constraints, then assigns up to three miners while keeping at
least three workers elsewhere. This first version opens one AI expansion.

Reproduce a layout:
`godot --path . -- --map-seed=17`
The explicit seed is retained when restarting that run.
Use `--fixed-map` to retain the original map. Existing `--classic`,
`--self-test` and staged video scenarios keep the original layout.
`--supply-video --map-seed=17` runs the full 4x review match on this seed.

Validation: scripts/expansion_map_audit.gd checks ten seeds / 100 expansion
pads, mirrored resources, crossing connectivity, expanded fog dimensions,
paid camp construction, actual local delivery, destroyed-camp fallback and
AI construction / miner assignment.
Generator: scripts/random_map.gd. It uses its own RandomNumberGenerator so
map generation does not consume battle/audio random state.

## Cohesive objective AI

scripts/army_plan.gd replaces per-unit idle reassignment. At least four ready
soldiers gather before committing; reinforcements wait and depart in batches.
Known enemy strength includes health, unit roles, towers and attack upgrades.
Visible overwhelming contact recalls the whole committed group and enforces
a recovery interval. Enemy information is based on vision, with short-lived
memory of an observed objective's defenders. Imminent control defeat bypasses
the minimum group size. Existing urgent home-defense logic takes priority.

scripts/army_plan_audit.gd verifies batching, refusal of known losing fights,
waiting reinforcements, coherent withdrawal and emergency commitment.

## Full large-map review (2026-11-08)

Seed 19, three bridges, normal economy and current combat rules. Blue uses
match_driver's scripted player; red uses opponent AI. `--observe-match` exposes
only rendering visibility; logical fog queries used by both agents are unchanged.
Camera alternates economy and center at 4x playback. Run with `--supply-video
--observe-match --map-seed=19` plus Godot movie options.

Observed: blue destroyed the red town center at 127.43 seconds. Blue began its
camp at 76.5 s, completed at 95.43 s, and delivered 285 gold there. Red built no
camp. Red trained only three soldiers and lost four workers; neither side reached
blacksmith upgrades or siege. This sample demonstrates working local delivery,
but fails to demonstrate successful red expansion or a sustained midgame.
Next balancing focus: early defense, worker survival / economic recovery, and
production priorities before extending the map or adding more content.

Video: captures/large-map-1v1.mp4 (32.63 seconds, 1440×900, 4x).
Metrics: captures/large-map-1v1-metrics.json. Legacy `first_contact`,
`player_expansion`, `player_assaults`, `enemy_attacks` fields track classic-mode
routes and are not meaningful here; use camp_events, mining_camps and
army_launches for this mode.

## AI recovery revision (2026-11-08)

Removed the red AI's five-soldier cap before 150 seconds. It now supports eight
workers and five gold miners, continues normal paid troop production up to 16,
and falls back to an affordable spearman when its preferred unit is unaffordable.
A barracks' own production count chooses its roster; worker production no longer
changes military composition. Under attack it rallies reinforcements at home,
reserves funds for defenders over replacing nonessential workers, and defers
research / advanced construction. A paid defensive tower is considered after
50 seconds with at least four soldiers and sufficient wood. Expansion is deferred
only during urgent home defense.

Evacuating workers now execute escape movement before delivery logic, retaining
cargo. Threatened workers can refresh their escape direction every two seconds;
existing danger-clear cooldown restores their prior job. No income, health,
vision or damage bonuses were added.

Same-seed full recorded result: blue won by control at 471.53 seconds, 180 vs
179.60. Red camp started 85.8 s, completed 103.27 s, and received 2695 gold / 111
wood. Blue camp received 2685 gold / 339 wood. Both teams reached attack 2 and
armor 2. Red delivered 6372 resources and trained 49 units including workers.
Siege attacks were still zero; the late game remains unproven by this sample.
Video: captures/large-map-recovery.mp4; metrics: large-map-recovery-metrics.json.
The previous recording and metrics remain under large-map-1v1.*.
Validation: defense_audit.gd --classic, ai_recovery_audit.gd --map-seed=19,
and the complete --self-test passed. This is one sample, not a win-rate estimate.

## Field army / local defense coordination

Local alerts no longer suspend every objective decision: the defense module
reserves only its current assigned soldiers; the objective planner excludes
those defenders and can command the remaining field army. Urgent home defense
still takes priority. The defender list is refreshed when the threat shrinks.
Uncaptured objectives no longer return before processing reserves. Reinforcements
still require batches of four, but strength checks include the existing field
army; if that combined force cannot contest its objective, an available weaker
alternative objective can be considered. Losing fights and recovery cooldowns
remain guarded. This is objective coordination, not a complete expansion-raiding
or multi-route flanking AI.

army_plan_audit.gd now covers combined-strength reinforcement of an uncaptured
objective and simultaneous local defense / field deployment, alongside its
existing batching, retreat and emergency checks. defense_audit.gd also passes.

Recorded coordination revision: seed 19, red control victory at 264.30 s (blue
0 / red 180). Red camp delivered 1806 gold and 6 wood; both teams reached attack
2 / armor 1. Video captures/coordinated-ai.mp4 is 66.83 s at 4x, ending with the
new compact result card. Metrics are captures/coordinated-ai-metrics.json.
The full match verifies integration; the precise reserve/defender edge cases are
covered by the focused audits. Holding an owned scoring point is intentional;
this run is not evidence that every possible idle-army situation is resolved.

## Blue-side fog review

`--supply-video --blue-vision-review --map-seed=19` records the normal blue fog
view without `--observe-match`. The review camera follows friendly buildings,
friendly units and their currently visible contacts; it never switches to the
red economy. Exploration, fading, minimap masks and enemy visibility use the
normal fog system. Metrics go to captures/blue-vision-match-metrics.json.

Base-only victory recording: seed 19, blue fog view, red destroyed blue Town
Center at 169.8 s. captures/base-victory-match.mp4 (43.2 s at 4x) includes the
base assault and the Town Center destroyed result. The camera prioritizes visible
threats within 450 px of the friendly home. Metrics: base-victory-match-metrics.json.
Supply audit: 24 checks passed, including 600 seconds of camp ownership without
victory and actual base destruction. Army audit covers moving on from a captured
camp to the opposing starting base. This sample is still a short early assault;
removing score victory alone does not guarantee a longer economic game.
