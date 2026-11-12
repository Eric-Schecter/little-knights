# Little Knights

![Little Knights](assets/covers/little-knights-cover-v1.png)

A cute 2D real-time strategy game. Gather resources, build an army, expand your base and destroy the enemy Town Center.

[Play in your browser](https://eric-schecter.github.io/little-knights/)

## How to Play

- **Left-click / drag:** Select units. **Shift:** Add to selection.
- **Right-click:** Move, attack, gather or repair a friendly building.
- **A + left-click:** Attack-move. **H:** Stop. **Z:** Toggle workers' auto repair.
- **Screen edges / arrow keys / middle-button drag:** Move the camera.
- **Minimap:** Click or drag to jump to a location.
- **Ctrl / Command + 1–9:** Save a group. Press its number to select; double-press to locate.
- Select a production building and right-click to set its rally point. Town Centers can rally workers onto resources.
- Open the top-right settings for pause, volume, fullscreen and restart.

## Run Locally

Open `project.godot` in **Godot 4.7.2**, then press **F6** in `main.tscn` or **F5**.

To export the Web build, install matching export templates and run `./tools/export_web.sh`. Serve `build/web` through HTTP; opening the HTML file directly is unsupported. Pushes to `main` build and deploy GitHub Pages automatically.

Art and cover were generated with AI. Music and sound effects use CC0 sources; see [asset credits](assets/SOURCES.md).
