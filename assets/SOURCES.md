# Asset credits

## Art

The active `knights/` sprite atlases and `covers/little-knights-cover-v1.png` were generated with AI for Little Knights. Runtime rendering, sprite slicing, shadows and UI icons are implemented in this repository.

Early reference-game sprites, retired animal/toy concepts and superseded tower atlases have been removed.

## Audio

- Sound effects: [Kenney RPG Audio](https://kenney.nl/assets/rpg-audio), CC0. [License](audio/kenney-rpg/LICENSE.txt).
- Event mixes: derived from those CC0 samples, with locally synthesized cannon layers. Recipes and build scripts are in `audio/knights-mix/`.
- Menu music: [The Old Tower Inn](https://opengameart.org/content/medieval-the-old-tower-inn) by RandomMind, CC0.
- Match music: [War Theme, version 2](https://opengameart.org/content/war-theme) by Spring Spring, CC0.

Music is converted to Ogg Vorbis and loudness-normalized.

Selection and construction/repair Foley variations are rebuilt from the retained CC0 Kenney sources with `assets/audio/knights-mix/build_interactions.py`.
