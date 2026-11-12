# Little Knights event mixes

Derived from Kenney RPG Audio (CC0). Original license: ../kenney-rpg/LICENSE.txt.
Original source: https://kenney.nl/assets/rpg-audio

Rebuild with python3 build_samples.py (ffmpeg required), then python3 build_notifications.py. recipes.json records layers, delays, gains and filters. No synthesized voice acting is included.

Mining: muted stone-like knock, no metal pots, 1.7 kHz low-pass.
Combat: short cloth/swish and dull impact; quiet latch only for armor/bolt.
Collapse: creaking timber and staggered debris impacts.
Death: cloth/leather fall. Ready: cloth/equipment adjustment followed by two soft footsteps. Complete: a final wooden knock and short structural settling sound. Both are material-based, without musical notes; build_notifications.py records exact source layers and processing.
Command: brief belt/equipment acknowledgement, once per player command.

Gameplay volume/pitch, visibility rules and dedicated queued notification voice, temporary 7 dB scene ducking and event voices: scripts/game_audio.gd.

Tower branches: build_towers.py / tower-recipes.json derive five local WAVs from
existing Kenney RPG CC0 samples. Repeater uses latch/click/cloth, heavy ballista
uses slowed creak/wood-door/knife whoosh, lookout uses cloth and a quiet filtered
metal-pot ring. Dedicated heavy and lookout impacts complete the set. Event
volumes and per-branch throttles are in game_audio.gd; visibility gating is retained.

Cannon revision: tower_cannon.wav layers CC0 doorClose_3 with generated brown
noise and an 85 Hz decaying tone, filtered and limited. tower_cannon_hit.wav is
its lower, shorter impact variant. Arrow retains tower_rapid.wav. Old branch
samples remain archived but no selectable tower uses lookout/heavy-ballista audio.

Cannon v2: build_cannon_v2.py adds a short filtered pink-noise pressure crack to
the previous cannon sample, strengthens the 160 Hz body, compresses the transient
and limits peak to 0.89. The impact has a shorter 220 Hz body, independently mixed.
Runtime launch gain rises from -10 to -4 dB, impact from -14 to -9 dB. Two dedicated
cannon voices prevent infantry/footsteps from taking all available voices; a new
launch can replace the older cannon voice. Existing visibility gating remains.
