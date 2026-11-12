# Little Knights 2D art pass

Generated using built-in image_gen, based on the approved B character sheet and battlefield concept. Original PNGs are retained; runtime slices their transparent cells. The props atlas upper row uses an x=720 cut to preserve the large oak canopy. No 3D scene is used in the active RTS.

Units: 4 columns (idle, walk A, walk B, action), 6 rows (teal worker/knight/crossbow, coral equivalents). This is a first animation pass, not full directional animation. Buildings: 4 columns x 2 rows. Terrain: grass/water panels. Props: two trees, ore, logs.

Current playable renderer: scripts/woodland_art.gd. Existing 2D economic and control-point rules remain active.

## Exact generation prompts

### bridge.png

Production 2D game sprite of ONE short sturdy wooden bridge for the approved Little Knights RTS battlefield reference. Genuine transparent background. Elevated orthographic camera looking down about 45 degrees, looking straight toward the north, NO diagonal rotation: bridge runs HORIZONTALLY LEFT TO RIGHT across the image, both entrances centered at left and right. Rectangular walking deck about 2 times wider than its visible screen depth, with chunky weathered warm brown wooden planks, low rail beams on the north and south edges, four short square timber posts, pale stone abutments at the LEFT and RIGHT ends. All parts fully within frame with clear margins. Compact low bridge, not a tall arch, no hanging ropes. Painterly warm shading and beveled edges matching reference, highlights upper left, darker lower/front side with visible small thickness. No water, no terrain, no grass, no people, no text, no cast shadow outside object. Asset should look inhabited and crafted, not smooth toy blocks or thin procedural lines.

Runtime draws the bridge in three horizontal bands: proportional rear/front rails and a stretched deck matching the existing crossing navigation bounds. The source atlas is preserved.

### units.png

Reference: exec-e71234af-052a-4d60-a279-13060cd50cad.png

Production 2D sprite atlas for the approved LITTLE KNIGHTS RTS art style in reference. Hand-painted rounded forms, convincing volume, consistent elevated three-quarter orthographic camera 40 degrees down, warm upper-left light, soft self-shading, crisp readable silhouette at small game scale. Not pixel art, not primitive 3D, not wooden peg dolls. NO text, NO labels, NO grid lines, no cast shadows or background tiles. Full objects with clean genuinely transparent space and padding between cells. Strict equal-cell layout. EXACT 4 COLUMNS x 6 ROWS on portrait canvas. Each cell ONE entire human character, 24 total. Rows 1-3 teal team: apron craftsman worker with pickaxe and soft cap; steel helmet shield-and-sword knight with teal short cape, gold shield trim; helmeted light crossbow soldier with teal cape. Rows 4-6 same respective characters with coral faction cloth and shields. Columns animation: idle ready stance; walk left foot forward/right arm back; walk right foot forward/left arm back; action (worker overhead pickaxe strike, knight extended sword slash, crossbow soldier aiming and firing). Face right three-quarter in every cell. Strongly distinct leg silhouettes between walk poses. Consistent identity, proportions, scale and foot baseline across each row, three heads tall, helmeted friendly humans only. No animals. Keep sword/shield and crossbow exactly recognizable from B design.

### buildings.png

Reference: exec-3d4e6aef-fc74-410c-a99c-d6272bdd06e4.png

Production 2D sprite atlas for the approved LITTLE KNIGHTS RTS art style in reference. Hand-painted rounded forms, convincing volume, consistent elevated three-quarter orthographic camera 40 degrees down, warm upper-left light, soft self-shading, crisp readable silhouette at small game scale. Not pixel art, not primitive 3D, not wooden peg dolls. NO text, NO labels, NO grid lines, no cast shadows or background tiles. Full objects with clean genuinely transparent space and padding between cells. Strict equal-cell layout. EXACT 4 COLUMNS x 2 ROWS on landscape 2:1 canvas. Eight separate buildings, one fully within each equal cell. Columns: welcoming stone-and-timber town hall with arched doorway, stepped foundation and small chimney; open-front barracks with weapon rack and target; cozy small cottage; slender stone watchtower with timber roof and open guard platform. Row1 teal shingle roofs and teal faction banners. Row2 identical types with coral shingle roofs and banners. Match the reference battlefield houses closely, warm plaster infill, pale stone blocks, brown timber braces, rounded teal roof tiles. No toy blocks. Building bases end cleanly at lowest stone step; no dirt oval, no surrounding scene, no attached trees. All eight cells same camera and light, no cropping.

### props.png

Reference: exec-3d4e6aef-fc74-410c-a99c-d6272bdd06e4.png

Production 2D sprite atlas for the approved LITTLE KNIGHTS RTS art style in reference. Hand-painted rounded forms, convincing volume, consistent elevated three-quarter orthographic camera 40 degrees down, warm upper-left light, soft self-shading, crisp readable silhouette at small game scale. Not pixel art, not primitive 3D, not wooden peg dolls. NO text, NO labels, NO grid lines, no cast shadows or background tiles. Full objects with clean genuinely transparent space and padding between cells. Strict equal-cell layout. EXACT 2 COLUMNS x 2 ROWS on square canvas. Four isolated full objects. Top left: broad rounded oak with irregular clustered sculpted green canopy, branching trunk and small grounded roots. Top right: smaller young tree with asymmetric clustered leafy crown and visible trunk/roots. Bottom left: low gray rocky gold ore deposit with warm yellow embedded mineral chunks, NOT coins. Bottom right: small stack of chopped timber logs with light cut ends. Trees match the lush chunky painterly trees in the battlefield reference, NOT wool balls, not textile cutouts, not identical sphere clusters. Consistent camera. No surrounding scenery.

### terrain.png

Reference: exec-3d4e6aef-fc74-410c-a99c-d6272bdd06e4.png

Flat production material atlas for approved LITTLE KNIGHTS hand-painted RTS battlefield. EXACT TWO equal square panels side by side, no gap, no labels, no border. Left half: uniform muted sage and warm olive grassy ground texture, low contrast subtle painterly short grass marks, sparse tiny tonal variation, no tall grass, no plants/trees/flowers/rocks, no paths, no lighting gradient, no cast shadows. Right half: uniform desaturated turquoise river water texture, very subtle soft flowing strokes, restrained thin pale ripples, no banks, no objects, no glints. Both flat overhead orthographic uniform textures, seamless-looking edges. Match reference battlefield palette with restrained detail and lower contrast so troops stand out. Not cloth, not felt, not photo textures.


### depot.png

Original ImageGen mining-camp atlas, two columns / one row, teal and coral teams.
Generated 2026-11-07 with expansion.png as the visual reference. Timber-and-stone
warehouse, open loading bay, ore cart, sacks and stored lumber; transparent
background and no baked cast shadow. Runtime slicing and ground-shadow pipeline
match the existing buildings. Source: exec-4e371a22-c222-4b4b-983d-dc7d07e81756.png.

### towers-distinct-v4.png

Active two-column / two-team tower atlas. Arrow towers use tall pointed roofs and twin crossbows; cannon towers use broad reinforced platforms and large cannon muzzles. Generated as an edit of the previous tower art, retaining the original stone base. Runtime icons crop to the weapon platform.
